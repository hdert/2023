//! A library for taking in user equations and evaluating them.
//! TODO:
//! - Add support for errors that show where the error originated
//! - Add support for multi-character operators
//! - Add support for arbitrary functions that can be passed in by the caller.

const std = @import("std");
const Stack = @import("Stack");
const testing = std.testing;
comptime {
    _ = @import("CalculatorLibTests.zig");
}

pub const Error = error{
    InvalidOperator,
    DivisionByZero,
    EmptyInput,
    SequentialOperators,
    EndsWithOperator,
    ParenEndsWithOperator,
    ParenMismatched,
    InvalidFloat,
};

fn printError(err: anyerror, stdout: std.fs.File.Writer) !void {
    switch (err) {
        Error.InvalidOperator => try stdout.print("You have entered an invalid operator\n", .{}),
        Error.DivisionByZero => try stdout.print("Cannot divide by zero\n", .{}),
        Error.EmptyInput => try stdout.print("You cannot have an empty input\n", .{}),
        Error.SequentialOperators => try stdout.print("You cannot enter sequential operators\n", .{}),
        Error.EndsWithOperator => try stdout.print("You cannot finish with an operator\n", .{}),
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

    pub fn init(buffer: []u8, stdout: std.fs.File.Writer, stdin: std.fs.File.Reader, allocator: std.mem.Allocator) !Self {
        while (true) {
            try stdout.print("Enter your equation: ", .{});
            const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
            if (Self.fromString(user_input, stdout, allocator)) |result| {
                return result;
            } else |err| {
                switch (err) {
                    Error.DivisionByZero => unreachable,
                    // This will return if there is a non-internal error
                    else => try printError(err, stdout),
                }
            }
        }
    }

    pub fn fromString(input: ?[]const u8, stdout: ?std.fs.File.Writer, allocator: std.mem.Allocator) !Self {
        return Self{
            .data = Self.validateInput(input) catch |err| switch (err) {
                Error.DivisionByZero => unreachable,
                else => {
                    if (stdout) |out| try printError(err, out);
                    return err;
                },
            },
            .stdout = stdout,
            .allocator = allocator,
        };
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
        const postfixEquation = try PostfixEquation.fromInfixEquation(self);
        defer postfixEquation.free();
        return postfixEquation.evaluate(previousAnswer orelse 0);
    }

    // Private functions

    fn validateInput(input: ?[]const u8) ![]const u8 {
        var isOperator = true;
        var isFloat = false;
        var paren_counter: isize = 0;
        var result: []const u8 = input orelse return Error.EmptyInput;
        if (@import("builtin").os.tag == .windows) {
            result = std.mem.trimRight(u8, result, "\r");
        }
        if (result.len == 0) return Error.EmptyInput;
        for (result) |char| {
            switch (char) {
                ' ' => continue,
                '0'...'9', 'a' => {
                    isOperator = false;
                },
                '.' => {
                    if (isFloat) {
                        return Error.InvalidFloat;
                    }
                    isFloat = true;
                    isOperator = false;
                },
                '(' => {
                    isOperator = true;
                    isFloat = false;
                    paren_counter += 1;
                },
                ')' => {
                    isFloat = false;
                    if (isOperator) {
                        return Error.ParenEndsWithOperator;
                    }
                    paren_counter -= 1;
                    if (paren_counter < 0) {
                        return Error.ParenMismatched;
                    }
                },
                else => {
                    const operator = @as(Operator, @enumFromInt(char));
                    _ = try operator.precedence();
                    if (isOperator and operator != Operator.subtraction) {
                        return Error.SequentialOperators;
                    }
                    isOperator = true;
                    isFloat = false;
                },
            }
        }
        if (isOperator) {
            return Error.EndsWithOperator;
        }
        return result;
    }
};

pub const PostfixEquation = struct {
    const Self = @This();

    data: []const u8,
    stdout: ?std.fs.File.Writer = null,
    allocator: std.mem.Allocator,

    pub fn fromInfixEquation(equation: InfixEquation) !Self {
        return Self{
            .data = try Self.infixToPostfix(equation),
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
                                if (self.stdout) |out| try printError(err, out);
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
        var isNumber = false;
        var wasNumber = false;
        var isNegative = false;
        var output = std.ArrayList(u8).init(equation.allocator);
        defer output.deinit();
        for (equation.data) |char| {
            std.debug.assert(if (!isNumber) !wasNumber else true);
            std.debug.assert(!(isNegative and isNumber));
            switch (char) {
                ' ' => wasNumber = isNumber,
                '0'...'9', '.' => {
                    if (isNegative) {
                        try output.append('-');
                    }
                    if (char == '.' and !isNumber) {
                        try output.append('0');
                    }
                    if (wasNumber) {
                        wasNumber = false;
                        try Self.addOperatorToStack(&stack, .multiplication, &output);
                    }
                    isNumber = true;
                    isNegative = false;
                    try output.append(char);
                },
                'a' => {
                    if (isNegative) {
                        try output.append('-');
                    } else if (isNumber) {
                        try Self.addOperatorToStack(&stack, .multiplication, &output);
                    }
                    try output.append(char);
                    isNumber = true;
                    wasNumber = true;
                    isNegative = false;
                },
                '(' => {
                    if (isNegative) {
                        try output.appendSlice("-1");
                        try Self.addOperatorToStack(&stack, .multiplication, &output);
                    } else if (isNumber) {
                        isNumber = false;
                        wasNumber = false;
                        try Self.addOperatorToStack(&stack, .multiplication, &output);
                    }
                    try stack.push(.left_paren);
                    isNegative = false;
                },
                ')' => {
                    // Invariant that isNumber == true upheld as we are guarenteed the parenthesis section ends with a number
                    std.debug.assert(isNumber == true);
                    std.debug.assert(isNegative == false);
                    wasNumber = true;
                    while (stack.peek() != Operator.left_paren) {
                        try output.append(' ');
                        try output.append(@intFromEnum(stack.pop()));
                    }
                    _ = stack.pop();
                },
                else => {
                    if (!isNumber) {
                        // We are guarenteed that char is subtraction by the validateInput function.
                        std.debug.assert(char == '-');
                        isNegative = !isNegative; // Deal with multiple negatives
                    } else {
                        try Self.addOperatorToStack(&stack, @enumFromInt(char), &output);
                        isNumber = false;
                        wasNumber = false;
                    }
                },
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
