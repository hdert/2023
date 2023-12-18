//! A library for taking in user equations and evaluating them.
//! TODO:
//! - Write a proper lexer to reduce size of conversion code
//! - Add support for multi-character operators
//!     - Requirements:
//!         - Allow more than 26 multi-character opererators
//!             - I.e. Don't implement as a one char lookup table
//!         - Use a modifiable lookup table for next feature
//! - Add support for arbitrary functions that can be passed in by the caller.

const std = @import("std");
const Stack = @import("Stack");
const testing = std.testing;
comptime {
    _ = @import("CalculatorLibTests.zig");
}

pub const Error = error{
    InvalidOperator,
    InvalidKeyword,
    DivisionByZero,
    EmptyInput,
    SequentialOperators,
    EndsWithOperator,
    StartsWithOperator,
    ParenEmptyInput,
    ParenStartsWithOperator,
    ParenEndsWithOperator,
    ParenMismatched,
    InvalidFloat,
};

fn printError(err: anyerror, stdout: std.fs.File.Writer, location: ?[3]usize, equation: ?[]const u8) !void {
    // const prompt_length = 21;
    if (location) |l| {
        std.debug.assert(l[1] >= l[0]);
        std.debug.assert(equation != null);
        try stdout.print("{?s}\n", .{equation});
        // for (prompt_length) |_| try stdout.print(" ", .{});
        for (l[0]) |_| try stdout.print("-", .{});
        for (l[1] - l[0]) |_| try stdout.print("^", .{});
        for (l[2] - l[1]) |_| try stdout.print("-", .{});
        try stdout.print("\n", .{});
    }
    switch (err) {
        Error.InvalidOperator => try stdout.print("You have entered an invalid operator\n", .{}),
        Error.InvalidKeyword => try stdout.print("You have entered an invalid keyword\n", .{}),
        Error.DivisionByZero => try stdout.print("Cannot divide by zero\n", .{}),
        Error.EmptyInput => try stdout.print("You cannot have an empty input\n", .{}),
        Error.SequentialOperators => try stdout.print("You cannot enter sequential operators\n", .{}),
        Error.EndsWithOperator => try stdout.print("You cannot finish with an operator\n", .{}),
        Error.StartsWithOperator => try stdout.print("You cannot start with an operator\n", .{}),
        Error.ParenEmptyInput => try stdout.print("You cannot have an empty parenthesis block\n", .{}),
        Error.ParenStartsWithOperator => try stdout.print("You cannot start a parentheses block with an operator\n", .{}),
        Error.ParenEndsWithOperator => try stdout.print("You cannot end a parentheses block with an operator\n", .{}),
        Error.ParenMismatched => try stdout.print("Mismatched parentheses!\n", .{}),
        Error.InvalidFloat => try stdout.print("You cannot have more than one period in a floating point number\n", .{}),
        else => return err,
    }
}

const Operator = enum(u8) {
    const Self = @This();

    addition = '+',
    subtraction = '-',
    division = '/',
    multiplication = '*',
    exponentiation = '^',
    modulus = '%',
    left_paren = '(',
    right_paren = ')',
    _,

    fn precedence(self: Self) !u8 {
        return switch (self) {
            .left_paren => 1,
            .addition => 2,
            .subtraction => 2,
            .multiplication => 3,
            .division => 3,
            .modulus => 3,
            .exponentiation => 4,
            .right_paren => 5,
            else => Error.InvalidOperator,
        };
    }

    fn higherOrEqual(self: Self, operator: Self) !bool {
        return try self.precedence() >= try Operator.precedence(operator);
    }
};

pub fn printResult(result: f64, stdout: std.fs.File.Writer) !void {
    const abs_result = if (result < 0) -result else result;
    const small = abs_result < std.math.pow(f64, 10, -9);
    const big = abs_result > std.math.pow(f64, 10, 9);
    if (!(big or small) or result == 0) {
        try stdout.print("The result is {d}\n", .{result});
    } else {
        try stdout.print("The result is {e}\n", .{result});
    }
}

pub const InfixEquation = struct {
    const Self = @This();

    data: []const u8,
    stdout: ?std.fs.File.Writer = null,
    allocator: std.mem.Allocator,
    error_info: ?[3]usize = null,

    pub fn init(buffer: []u8, stdout: std.fs.File.Writer, stdin: std.fs.File.Reader, allocator: std.mem.Allocator) !Self {
        while (true) {
            try stdout.print("Enter your equation: ", .{});
            const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
            if (fromString(user_input, stdout, allocator)) |result| {
                return result;
            } else |_| {}
        }
    }

    pub fn fromString(input: ?[]const u8, stdout: ?std.fs.File.Writer, allocator: std.mem.Allocator) !Self {
        var self = Self{
            .data = undefined,
            .stdout = stdout,
            .allocator = allocator,
        };
        validateInput(&self, input) catch |err| switch (err) {
            Error.DivisionByZero => unreachable,
            else => {
                if (stdout) |out| try printError(err, out, null, null);
                return err;
            },
        };
        return self;
    }

    pub fn toPostfixEquation(self: Self) !PostfixEquation {
        return PostfixEquation.fromInfixEquation(self);
    }

    /// Evaluate an infix expression.
    /// This chains together a bunch of library functions to do this.
    /// previousAnswer defaults to 0
    /// If InfixEquation has a valid stdout, prints errors to it using printError.
    /// Passes errors back to caller regardless of stdout being defined.
    pub fn evaluate(self: Self, previousAnswer: ?f64) !f64 {
        const postfixEquation = try self.toPostfixEquation();
        defer postfixEquation.free();
        return postfixEquation.evaluate(previousAnswer orelse 0);
    }

    // Private functions

    fn validateInput(self: *Self, input: ?[]const u8) !void {
        self.data = input orelse return Error.EmptyInput;
        if (@import("builtin").os.tag == .windows) {
            self.data = std.mem.trimRight(u8, self.data, "\r");
        }
        self.data = std.mem.trim(u8, self.data, " ");
        var tokens = Tokenizer.init(self.data);
        const State = enum {
            float,
            start,
            keyword,
            operator,
            paren,
            minus,
        };
        var state = State.start;
        var paren_counter: isize = 0;
        while (true) {
            const token = tokens.next();
            switch (token.tag) {
                .invalid_float => return Error.InvalidFloat,
                .invalid => return Error.InvalidKeyword,
                .eol => switch (state) {
                    .start => return Error.EmptyInput,
                    .operator, .paren, .minus => return Error.EndsWithOperator,
                    .float, .keyword => break,
                },
                .operator => switch (state) {
                    .start => return Error.StartsWithOperator,
                    .operator, .minus => return Error.SequentialOperators,
                    .paren => return Error.ParenStartsWithOperator,
                    .float, .keyword => state = .operator,
                },
                .float => state = .float,
                .minus => switch (state) {
                    .start, .operator, .paren, .minus => state = .minus,
                    .float, .keyword => state = .operator,
                },
                .left_paren => {
                    paren_counter += 1;
                    state = .paren;
                },
                .right_paren => switch (state) {
                    .start => return Error.ParenMismatched,
                    .operator, .minus => return Error.ParenEndsWithOperator,
                    .paren => return Error.ParenEmptyInput,
                    .float, .keyword => {
                        paren_counter -= 1;
                        if (paren_counter < 0) {
                            return Error.ParenMismatched;
                        }
                        state = .float;
                    },
                },
                .keyword => {
                    if (token.slice.len != 1 or token.slice[0] != 'a') {
                        return Error.InvalidKeyword;
                    }
                    state = .keyword;
                },
            }
        }
        if (paren_counter > 0) {
            return Error.ParenMismatched;
        }
        if (state == .operator) {
            return Error.EndsWithOperator;
        }
    }

    /// Takes Self, returns allocated tokens.
    const Tokenizer = struct {
        buffer: []const u8,
        index: usize,

        const State = enum {
            float,
            float_decimals,
            keyword,
            start,
        };

        fn init(buffer: []const u8) Tokenizer {
            return Tokenizer{
                .buffer = buffer,
                .index = 0,
            };
        }

        pub fn next(self: *Tokenizer) Token {
            var result = Token{
                .slice = undefined,
                .tag = .eol,
            };
            var start = self.index;
            var state = State.start;
            while (self.index < self.buffer.len) : (self.index += 1) {
                const c = self.buffer[self.index];
                switch (state) {
                    .start => switch (c) {
                        ' ' => {
                            start = self.index + 1;
                            continue;
                        },
                        0, '\n', '\t', '\r' => break,
                        '0'...'9' => {
                            state = .float;
                            result.tag = .float;
                        },
                        '.' => {
                            state = .float_decimals;
                            result.tag = .float;
                        },
                        '+', '/', '*', '^', '%' => {
                            result.tag = .operator;
                            self.index += 1;
                            break;
                        },
                        '-' => {
                            result.tag = .minus;
                            self.index += 1;
                            break;
                        },
                        '(' => {
                            result.tag = .left_paren;
                            self.index += 1;
                            break;
                        },
                        ')' => {
                            result.tag = .right_paren;
                            self.index += 1;
                            break;
                        },
                        'a'...'z', 'A'...'Z' => {
                            result.tag = .keyword;
                            state = .keyword;
                        },
                        else => {
                            result.tag = .invalid;
                            break;
                        },
                    },
                    .float => switch (c) {
                        '0'...'9' => continue,
                        '.' => state = .float_decimals,
                        else => break,
                    },
                    .float_decimals => switch (c) {
                        '0'...'9' => continue,
                        '.' => {
                            result.tag = .invalid_float;
                            break;
                        },
                        else => break,
                    },
                    .keyword => switch (c) {
                        'a'...'z', 'A'...'Z', '_' => continue,
                        else => break,
                    },
                }
            }
            result.slice = self.buffer[start..self.index];
            return result;
        }
    };

    const Token = struct {
        slice: []const u8,
        tag: Tag,

        const Tag = enum {
            float,
            invalid_float,
            operator,
            left_paren,
            right_paren,
            minus,
            keyword,
            eol,
            invalid,
        };
    };
};

pub const PostfixEquation = struct {
    const Self = @This();

    data: []const u8,
    stdout: ?std.fs.File.Writer = null,
    allocator: std.mem.Allocator,

    pub fn fromInfixEquation(equation: InfixEquation) !Self {
        return Self{
            .data = try infixToPostfix(equation),
            .stdout = equation.stdout,
            .allocator = equation.allocator,
        };
    }

    /// Evaluate a postfix expression.
    /// If PostfixEquation has a valid stdout, prints errors to it using printError.
    /// Passes errors back to caller regardless of stdout being defined.
    pub fn evaluate(self: Self, previousAnswer: f64) !f64 {
        var stack = Stack.Stack(f64).init(self.allocator);
        defer stack.free();
        var tokens = std.mem.tokenizeScalar(u8, self.data, ' ');
        while (tokens.next()) |token| {
            switch (token[token.len - 1]) {
                '0'...'9', '.' => {
                    try stack.push(try std.fmt.parseFloat(f64, token));
                },
                'a' => {
                    try stack.push(if (token[0] == '-') -previousAnswer else previousAnswer);
                },
                else => {
                    std.debug.assert(token.len == 1);
                    const value = stack.pop();
                    if (calculate(stack.pop(), value, token[0])) |result| {
                        try stack.push(result);
                    } else |err| {
                        switch (err) {
                            Error.DivisionByZero => {
                                if (self.stdout) |out| try printError(err, out, null, null);
                                return err;
                            },
                            else => unreachable,
                        }
                    }
                },
            }
        }
        defer std.debug.assert(stack.len() == 0);
        return stack.pop();
    }

    pub fn free(self: *const Self) void {
        self.allocator.free(self.data);
    }

    // Private functions

    fn addOperatorToStack(stack: *Stack.Stack(Operator), operator: Operator, output: *std.ArrayList(u8)) !void {
        while (stack.len() > 0 and try stack.peek().higherOrEqual(operator)) {
            try output.append(' ');
            try output.append(@intFromEnum(stack.pop()));
        }
        try output.append(' ');
        try stack.push(operator);
    }

    fn infixToPostfix(equation: InfixEquation) ![]u8 {
        var stack = Stack.Stack(Operator).init(equation.allocator);
        defer stack.free();
        var output = std.ArrayList(u8).init(equation.allocator);
        defer output.deinit();
        var tokens = InfixEquation.Tokenizer.init(equation.data);
        const State = enum { none, negative, float };
        var state = State.none;
        while (true) {
            const token = tokens.next();
            switch (token.tag) {
                .eol => break,
                .float => {
                    switch (state) {
                        .none => {},
                        .negative => try output.append('-'),
                        .float => {
                            try addOperatorToStack(&stack, .multiplication, &output);
                        },
                    }
                    if (token.slice[0] == '.') {
                        try output.append('0');
                    }
                    state = .float;
                    try output.appendSlice(token.slice);
                },
                .keyword => {
                    switch (state) {
                        .none => {},
                        .negative => try output.append('-'),
                        .float => {
                            try addOperatorToStack(&stack, .multiplication, &output);
                        },
                    }
                    state = .float;
                    try output.appendSlice(token.slice);
                },
                .minus => switch (state) {
                    .none => state = .negative,
                    .negative => state = .none,
                    .float => {
                        state = .none;
                        try addOperatorToStack(&stack, .subtraction, &output);
                    },
                },
                .left_paren => {
                    switch (state) {
                        .none => {},
                        .negative => {
                            try output.appendSlice("-1");
                            try addOperatorToStack(&stack, .multiplication, &output);
                        },
                        .float => {
                            try addOperatorToStack(&stack, .multiplication, &output);
                        },
                    }
                    state = .none;
                    try stack.push(.left_paren);
                },
                .right_paren => {
                    while (stack.peek() != Operator.left_paren) {
                        try output.append(' ');
                        try output.append(@intFromEnum(stack.pop()));
                    }
                    _ = stack.pop();
                    state = .float;
                },
                .operator => {
                    try addOperatorToStack(&stack, @enumFromInt(token.slice[0]), &output);
                    state = .none;
                },
                else => unreachable,
            }
        }
        while (stack.len() > 0) {
            try output.append(' ');
            try output.append(@intFromEnum(stack.pop()));
        }
        return output.toOwnedSlice();
    }

    fn calculate(number_1: f64, number_2: f64, operator: u8) Error!f64 {
        return switch (@as(Operator, @enumFromInt(operator))) {
            Operator.addition => number_1 + number_2,
            Operator.subtraction => number_1 - number_2,
            Operator.division => if (number_2 == 0) Error.DivisionByZero else number_1 / number_2,
            Operator.multiplication => number_1 * number_2,
            Operator.exponentiation => std.math.pow(f64, number_1, number_2),
            Operator.modulus => if (number_2 <= 0) Error.DivisionByZero else @mod(number_1, number_2),
            else => Error.InvalidOperator,
        };
    }
};

test "Operator.precedence validity" {
    const success_cases = .{
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
        '(',
        ')',
    };
    const fail_cases = .{
        'a',
        '1',
        '0',
        'w',
        '9',
        '&',
        '.',
        'a',
    };
    inline for (success_cases) |case| {
        _ = try @as(Operator, @enumFromInt(case)).precedence();
    }
    inline for (fail_cases) |case| {
        const result = @as(Operator, @enumFromInt(case)).precedence();
        try testing.expectError(Error.InvalidOperator, result);
    }
}

test "PostfixEquation.calculate" {
    const success_cases = .{
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
    };
    const success_case_numbers = [_]comptime_float{
        10, 10, 20,
        10, 10, 0,
        10, 10, 1,
        10, 10, 100,
        10, 2,  100,
        30, 10, 0,
    };
    try testing.expect(success_case_numbers.len % 3 == 0);
    try testing.expect(success_cases.len == success_case_numbers.len / 3);
    const fail_cases = .{
        '/',
        '%',
        'a',
        '&',
        '1',
    };

    const fail_case_numbers = .{
        10, 0,
        10, 0,
        10, 10,
        10, 10,
        10, 10,
    };
    try testing.expect(fail_case_numbers.len % 2 == 0);
    try testing.expect(fail_cases.len == fail_case_numbers.len / 2);
    inline for (0..success_cases.len) |i| {
        const result = try comptime PostfixEquation.calculate(success_case_numbers[i * 3], success_case_numbers[i * 3 + 1], success_cases[i]);
        try testing.expectEqual(success_case_numbers[i * 3 + 2], result);
    }
    inline for (0..fail_cases.len) |i| {
        if (PostfixEquation.calculate(fail_case_numbers[i * 2], fail_case_numbers[i * 2 + 1], fail_cases[i])) |_| {
            return error.NotFail;
        } else |_| {}
    }
}
