//! A library for taking in user equations and evaluating them.
//! TODO:
//! - Split tests into separate file
//! - Add support for errors that show where the error originated
//! - Add support for multi-character operators
//! - Add support for arbitrary functions that can be passed in by the caller.

const std = @import("std");
const Stack = @import("Stack");

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

pub fn printError(err: anyerror, stdout: std.fs.File.Writer) !void {
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

pub const Operator = enum(u8) {
    addition = '+',
    subtraction = '-',
    division = '/',
    multiplication = '*',
    exponentiation = '^',
    modulus = '%',
    left_paren = '(',
    right_paren = ')',
    _,

    pub fn precedence(self: @This()) !u8 {
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

    pub fn higherOrEqual(self: @This(), operator: @This()) !bool {
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

pub fn validateInput(input: ?[]const u8) ![]const u8 {
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

pub fn getInput(buffer: []u8, stdout: std.fs.File.Writer, stdin: std.fs.File.Reader) ![]const u8 {
    while (true) {
        try stdout.print("Enter your equation: ", .{});
        const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
        if (validateInput(user_input)) |result| {
            return result;
        } else |err| {
            switch (err) {
                Error.EmptyInput, Error.SequentialOperators, Error.InvalidOperator, Error.EndsWithOperator, Error.ParenEndsWithOperator, Error.ParenMismatched, Error.InvalidFloat => try printError(err, stdout),
                Error.DivisionByZero => unreachable,
                else => return err,
            }
        }
    }
}

fn addOperatorToStack(stack: *Stack.Stack(Operator), operator: Operator, output: *std.ArrayList(u8)) !void {
    while (stack.len() > 0 and try stack.peek().higherOrEqual(operator)) {
        try output.append(' ');
        try output.append(@intFromEnum(stack.pop()));
    }
    try output.append(' ');
    try stack.push(operator);
}

pub fn infixToPostfix(input: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var stack = Stack.Stack(Operator).init(allocator);
    defer stack.free();
    var isNumber = false;
    var wasNumber = false;
    var isNegative = false;
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    for (input) |char| {
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
                    try addOperatorToStack(&stack, .multiplication, &output);
                }
                isNumber = true;
                isNegative = false;
                try output.append(char);
            },
            'a' => {
                if (isNegative) {
                    try output.append('-');
                } else if (isNumber) {
                    try addOperatorToStack(&stack, .multiplication, &output);
                }
                try output.append(char);
                isNumber = true;
                wasNumber = true;
                isNegative = false;
            },
            '(' => {
                if (isNegative) {
                    try output.appendSlice("-1");
                    try addOperatorToStack(&stack, .multiplication, &output);
                } else if (isNumber) {
                    isNumber = false;
                    wasNumber = false;
                    try addOperatorToStack(&stack, .multiplication, &output);
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
                    try addOperatorToStack(&stack, @enumFromInt(char), &output);
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
    return try output.toOwnedSlice();
}

pub fn evaluate(number_1: f64, number_2: f64, operator: u8) Error!f64 {
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

pub fn evaluatePostfix(expression: []const u8, previousAnswer: f64, allocator: std.mem.Allocator) !f64 {
    var stack = Stack.Stack(f64).init(allocator);
    defer stack.free();
    var tokens = std.mem.tokenizeScalar(u8, expression, ' ');
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
                if (evaluate(stack.pop(), value, token[0])) |result| {
                    try stack.push(result);
                } else |err| {
                    switch (err) {
                        Error.DivisionByZero => return err,
                        else => unreachable,
                    }
                }
            },
        }
    }
    defer std.debug.assert(stack.len() == 0);
    return stack.pop();
}
