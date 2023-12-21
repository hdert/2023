//! A library for taking in user equations and evaluating them.
//! TODO:
//! - Create help and h keywords
//!     - This is not really a library problem, this is a front-end
//!     problem.
//!     - Maybe help could be a special error type?
//!     - What about wanting to call help on functions?
//!         - This is probably to big of an ask right now, especially
//!         if I want to automate it based off of function docstrings.
//! - Create ans and answer keywords
//!     - This is also a front-end problem, maybe I could create a
//!     no input only output function. Almost like a constants function.
//!     - It'd probably be better to implement this by just passing a number
//!     to the library
//!     - But then how'd you implement a help function?
//! - Add support for multi-character operators
//!     - Requirements:
//!         - Allow more than 26 multi-character opererators
//!             - I.e. Don't implement as a char lookup table
//!         - Use a modifiable lookup table for next feature
//!         - These are not allowed to be infix operators
//!         - These must be for functions only
//! - Add support for arbitrary functions that can be passed in by the caller.
//!     - Allow them to have a chosen amount of arguments (between zero and inf)
//!     - Allow them to take an array of arguments
//! - Create tests for Tokenizer
//!     - Depends on whether the code ever changes, and whether
//!     the public method testing covers it.
//! - Find way to do performance testing
//! - Merge InfixEquation and PostfixEquation into one Equation struct
//!     - This needs to done to make the code less awkward for the next part
//!     - But does it?
//!     - This has allowed me to keep a stable ABI despite numerous backend changes
//!     - I don't think this is necessary, I can just keep copying data
//! - Move functions that are actually the responsibility of the front-end
//! to there.

const std = @import("std");
const Stack = @import("Stack");
const Tokenizer = @import("Tokenizer.zig");
const Io = @import("CalculatorIo.zig");
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

pub fn isError(err: anyerror) bool {
    return switch (err) {
        Error.InvalidOperator,
        Error.InvalidKeyword,
        Error.DivisionByZero,
        Error.EmptyInput,
        Error.SequentialOperators,
        Error.EndsWithOperator,
        Error.StartsWithOperator,
        Error.ParenEmptyInput,
        Error.ParenStartsWithOperator,
        Error.ParenEndsWithOperator,
        Error.ParenMismatched,
        Error.InvalidFloat,
        => true,
        else => false,
    };
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

pub const InfixEquation = struct {
    const Self = @This();

    data: []const u8,
    stdout: ?std.fs.File.Writer = null,
    allocator: std.mem.Allocator,
    error_info: ?[3]usize = null,

    pub fn fromString(
        input: ?[]const u8,
        stdout: ?std.fs.File.Writer,
        allocator: std.mem.Allocator,
    ) !Self {
        var self = Self{
            .data = undefined,
            .stdout = stdout,
            .allocator = allocator,
        };
        validateInput(&self, input) catch |err| switch (err) {
            Error.DivisionByZero => unreachable,
            else => {
                if (stdout) |out| try Io.printError(
                    err,
                    out,
                    self.error_info,
                    self.data,
                );
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
        var old_error_info: ?[3]usize = null;
        while (true) {
            const token = tokens.next();
            self.error_info = .{ token.start, token.end, self.data.len };
            switch (token.tag) {
                .invalid_float => return Error.InvalidFloat,
                .invalid => return Error.InvalidKeyword,
                .eol => switch (state) {
                    .start => return Error.EmptyInput,
                    .operator, .paren, .minus => {
                        self.error_info = old_error_info;
                        return Error.EndsWithOperator;
                    },
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
                    .operator, .minus => {
                        self.error_info = old_error_info;
                        return Error.ParenEndsWithOperator;
                    },
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
            old_error_info = .{ token.start, token.end, self.data.len };
        }
        if (paren_counter > 0) {
            self.error_info = old_error_info;
            return Error.ParenMismatched;
        }
    }
};

/// Must be freed
pub const PostfixEquation = struct {
    const Self = @This();

    data: []const u8,
    stdout: ?std.fs.File.Writer = null,
    allocator: std.mem.Allocator,

    /// When created using this method, the resultant struct must be freed
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
                                if (self.stdout) |out| try Io.printError(err, out, null, null);
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

    fn addOperatorToStack(
        stack: *Stack.Stack(Operator),
        operator: Operator,
        output: *std.ArrayList(u8),
    ) !void {
        while (stack.len() > 0 and try stack.peek().higherOrEqual(operator)) {
            try output.append(' ');
            try output.append(@intFromEnum(stack.pop()));
        }
        try output.append(' ');
        try stack.push(operator);
    }

    /// Returns string that must be freed
    fn infixToPostfix(equation: InfixEquation) ![]u8 {
        var stack = Stack.Stack(Operator).init(equation.allocator);
        defer stack.free();
        var output = std.ArrayList(u8).init(equation.allocator);
        defer output.deinit();
        var tokens = Tokenizer.init(equation.data);
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
    const success_cases = .{ '+', '-', '/', '*', '^', '%', '(', ')' };
    const fail_cases = .{ 'a', '1', '0', 'w', '9', '&', '.', 'a' };
    inline for (success_cases) |case| {
        _ = try @as(Operator, @enumFromInt(case)).precedence();
    }
    inline for (fail_cases) |case| {
        const result = @as(Operator, @enumFromInt(case)).precedence();
        try testing.expectError(Error.InvalidOperator, result);
    }
}

test "PostfixEquation.calculate" {
    const success_cases = .{ '+', '-', '/', '*', '^', '%' };
    const success_case_numbers = [_]comptime_float{
        10, 10, 20,  10, 10, 0,
        10, 10, 1,   10, 10, 100,
        10, 2,  100, 30, 10, 0,
    };
    try testing.expect(success_case_numbers.len % 3 == 0);
    try testing.expect(success_cases.len == success_case_numbers.len / 3);
    const fail_cases = .{ '/', '%', 'a', '&', '1' };

    const fail_case_numbers = .{
        10, 0,  10, 0,  10,
        10, 10, 10, 10, 10,
    };
    try testing.expect(fail_case_numbers.len % 2 == 0);
    try testing.expect(fail_cases.len == fail_case_numbers.len / 2);
    inline for (0..success_cases.len) |i| {
        const result = try comptime PostfixEquation.calculate(
            success_case_numbers[i * 3],
            success_case_numbers[i * 3 + 1],
            success_cases[i],
        );
        try testing.expectEqual(success_case_numbers[i * 3 + 2], result);
    }
    inline for (0..fail_cases.len) |i| {
        if (PostfixEquation.calculate(
            fail_case_numbers[i * 2],
            fail_case_numbers[i * 2 + 1],
            fail_cases[i],
        )) |_| {
            return error.NotFail;
        } else |_| {}
    }
}
