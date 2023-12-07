const std = @import("std");
const Stack = @import("Stack");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

pub const CalculatorError = error{
    InvalidOperator,
    DivisionByZero,
    EmptyInput,
    SequentialOperators,
    EndsWithOperator,
    ParenEndsWithOperator,
    ParenMismatched,
    InvalidFloat,
};

const Operator = enum(u8) {
    addition = '+',
    subtraction = '-',
    division = '/',
    multiplication = '*',
    exponentiation = '^',
    modulus = '%',
    left_paren = '(',
    right_paren = ')',
    _,

    fn precedence(self: @This()) !u8 {
        return switch (self) {
            .left_paren => 1,
            .addition => 2,
            .subtraction => 2,
            .multiplication => 3,
            .division => 3,
            .modulus => 3,
            .exponentiation => 4,
            .right_paren => 5,
            else => CalculatorError.InvalidOperator,
        };
    }

    fn higherOrEqual(self: @This(), operator: @This()) !bool {
        return try self.precedence() >= try Operator.precedence(operator);
    }
};

fn validateInput(input: ?[]u8) ![]u8 {
    var isOperator = true;
    var isFloat = false;
    var paren_counter: isize = 0;
    var result: []u8 = undefined;
    result = input orelse return CalculatorError.EmptyInput;
    if (@import("builtin").os.tag == .windows) {
        result = std.mem.trimRight(u8, input orelse return CalculatorError.EmptyInput, "\r");
    }
    for (result) |char| {
        switch (char) {
            ' ' => continue,
            '0'...'9', 'a' => {
                isOperator = false;
            },
            '.' => {
                if (isFloat) {
                    return CalculatorError.InvalidFloat;
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
                    return CalculatorError.ParenEndsWithOperator;
                }
                paren_counter -= 1;
                if (paren_counter < 0) {
                    return CalculatorError.ParenMismatched;
                }
            },
            else => {
                if (isOperator) {
                    return CalculatorError.SequentialOperators;
                }
                _ = evaluate(1, 2, char) catch {
                    return CalculatorError.InvalidOperator;
                };
                isOperator = true;
                isFloat = false;
            },
        }
    }
    if (isOperator) {
        return CalculatorError.EndsWithOperator;
    }
    return result;
}

pub fn getInput(buffer: []u8) ![]u8 {
    while (true) {
        try stdout.print("Enter your equation: ", .{});
        const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
        if (validateInput(user_input)) |result| {
            return result;
        } else |err| {
            switch (err) {
                CalculatorError.EmptyInput => {
                    try stdout.print("You cannot have an empty input\n", .{});
                },
                CalculatorError.SequentialOperators => {
                    try stdout.print("You cannot enter sequential operators\n", .{});
                },
                CalculatorError.InvalidOperator => {
                    try stdout.print("You have entered an invalid operator", .{});
                },
                CalculatorError.EndsWithOperator => {
                    try stdout.print("You cannot finish with an operator\n", .{});
                },
                CalculatorError.ParenEndsWithOperator => {
                    try stdout.print("You cannot end a parentheses block with an operator\n", .{});
                },
                CalculatorError.ParenMismatched => {
                    try stdout.print("Mismatched parentheses!\n", .{});
                },
                CalculatorError.InvalidFloat => {
                    try stdout.print("You cannot have more than one period in a floating point number\n", .{});
                },
                CalculatorError.DivisionByZero => unreachable,
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

pub fn infixToPostfix(input: []u8, allocator: std.mem.Allocator) ![]u8 {
    var stack = Stack.Stack(Operator).init(allocator);
    defer stack.free();
    var isNumber = false;
    var wasNumber = false;
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    for (input) |char| {
        switch (char) {
            ' ' => wasNumber = isNumber,
            '0'...'9', '.' => {
                if (wasNumber) {
                    wasNumber = false;
                    try addOperatorToStack(&stack, .multiplication, &output);
                }
                isNumber = true;
                try output.append(char);
            },
            'a' => {
                if (isNumber) {
                    try addOperatorToStack(&stack, .multiplication, &output);
                }
                try output.append(char);
                isNumber = true;
                wasNumber = true;
            },
            '(' => {
                if (isNumber) {
                    isNumber = false;
                    wasNumber = false;
                    try addOperatorToStack(&stack, .multiplication, &output);
                }
                try stack.push(.left_paren);
            },
            ')' => {
                wasNumber = true;
                while (stack.peek() != Operator.left_paren) {
                    try output.append(' ');
                    try output.append(@intFromEnum(stack.pop()));
                }
                _ = stack.pop();
            },
            else => {
                try addOperatorToStack(&stack, @enumFromInt(char), &output);
                isNumber = false;
                wasNumber = false;
            },
        }
    }
    while (stack.len() > 0) {
        try output.append(' ');
        try output.append(@intFromEnum(stack.pop()));
    }
    return try output.toOwnedSlice();
}

fn evaluate(number_1: f64, number_2: f64, operator: u8) CalculatorError!f64 {
    return switch (@as(Operator, @enumFromInt(operator))) {
        Operator.addition => number_1 + number_2,
        Operator.subtraction => number_1 - number_2,
        Operator.division => if (number_2 == 0) CalculatorError.DivisionByZero else number_1 / number_2,
        Operator.multiplication => number_1 * number_2,
        Operator.exponentiation => std.math.pow(f64, number_1, number_2),
        Operator.modulus => if (number_2 <= 0) CalculatorError.DivisionByZero else @mod(number_1, number_2),
        else => CalculatorError.InvalidOperator,
    };
}

pub fn evaluatePostfix(expression: []u8, previousAnswer: f64, allocator: std.mem.Allocator) !f64 {
    var stack = Stack.Stack(f64).init(allocator);
    defer stack.free();
    var tokens = std.mem.tokenizeScalar(u8, expression, ' ');
    while (tokens.next()) |token| {
        switch (token[0]) {
            '0'...'9', '.' => {
                try stack.push(try std.fmt.parseFloat(f64, token));
            },
            'a' => {
                std.debug.assert(token.len == 1);
                try stack.push(previousAnswer);
            },
            else => {
                std.debug.assert(token.len == 1);
                const value = stack.pop();
                if (evaluate(value, stack.pop(), token[0])) |result| {
                    try stack.push(result);
                } else |err| {
                    switch (err) {
                        CalculatorError.DivisionByZero => {
                            try stdout.print("Cannot divide by 0\n", .{});
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

// TODO: Tests
