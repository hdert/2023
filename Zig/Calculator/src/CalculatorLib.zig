const std = @import("std");
const Stack = @import("Stack");
const testing = std.testing;

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

fn validateInput(input: ?[]const u8) ![]const u8 {
    var isOperator = true;
    var isFloat = false;
    var paren_counter: isize = 0;
    var result: []const u8 = input orelse return CalculatorError.EmptyInput;
    if (@import("builtin").os.tag == .windows) {
        result = std.mem.trimRight(u8, result, "\r");
    }
    if (result.len == 0) return CalculatorError.EmptyInput;
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
                _ = try @as(Operator, @enumFromInt(char)).precedence();
                if (isOperator) {
                    return CalculatorError.SequentialOperators;
                }
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

pub fn getInput(buffer: []u8, stdout: std.fs.File.Writer, stdin: std.fs.File.Reader) ![]const u8 {
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
                    try stdout.print("You have entered an invalid operator\n", .{});
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

pub fn infixToPostfix(input: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var stack = Stack.Stack(Operator).init(allocator);
    defer stack.free();
    var isNumber = false;
    var wasNumber = false;
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    for (input) |char| {
        std.debug.assert(if (!isNumber) !wasNumber else true);
        switch (char) {
            ' ' => wasNumber = isNumber,
            '0'...'9', '.' => {
                if (char == '.' and !isNumber) {
                    try output.append('0');
                }
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

pub fn evaluatePostfix(expression: []const u8, previousAnswer: f64, allocator: std.mem.Allocator) !f64 {
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
                if (evaluate(stack.pop(), value, token[0])) |result| {
                    try stack.push(result);
                } else |err| {
                    switch (err) {
                        CalculatorError.DivisionByZero => return err,
                        else => unreachable,
                    }
                }
            },
        }
    }
    defer std.debug.assert(stack.len() == 0);
    return stack.pop();
}

test "Operator.precedence() validity" {
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
        try testing.expectError(CalculatorError.InvalidOperator, @as(Operator, @enumFromInt(case)).precedence());
    }
}

test "validateInput()" {
    const success_cases = .{
        "10+10",
        "10 + 10",
        "    10+10 (20)",
        "10/10",
        "10 / (10)",
        "10*(10)",
        "10 * ( 10 ) ",
        "10",
        "10.10+10.10",
        "10.999",
        "10.789 * ( 10.123 )",
        "10 + a",
        "a",
        "a+a",
        ".123",
        ".",
        "123.",
        "10(10)",
        "10(10)10",
        "(10)10",
        "10 (10)",
        "10 10",
        "10 + 10 10",
        "10.123 10",
        "(10) 10",
        "a a",
        "aa",
        "10a",
        "10 a",
        "10 (a)",
        "a (10)",
        "10a10",
        "a10",
        "10 a 10",
        "a 10",
        "10 ^ 10 10",
        "aaa",
        "a a a",
        "aa a",
        "a aa",
    };
    const fail_cases = .{
        "10++10",
        "10(*10)",
        "10(10*)",
        "10*",
        "10(10)*",
        "()",
        "10()",
        "21 + 2 ) * ( 5 / 6",
        "10.789.",
        "10.789.123",
        "10..",
        "",
        null,
    };
    inline for (success_cases) |case| {
        try testing.expectEqualSlices(u8, case, try validateInput(case));
    }
    inline for (fail_cases) |case| {
        if (validateInput(case)) |_| {
            return error.NotFail;
        } else |_| {}
    }
}

test "infixToPostfix()" {
    const allocator = std.testing.allocator;
    const success_cases = [_][]const u8{
        "10+10",
        "10 10 +",
        "10 + 10",
        "10 10 +",
        "    10+10 *(20)",
        "10 10 20 * +",
        "    10+10 (20)",
        "10 10 20 * +",
        "10/10",
        "10 10 /",
        "10 / (10)",
        "10 10 /",
        // "10(10)",
        // "1010",
        "10*(10)",
        "10 10 *",
        "10 * ( 10 ) ",
        "10 10 *",
        "10",
        "10",
        "10 + (10 / 2 * 3) + 10",
        "10 10 2 / 3 * + 10 +",
        "10.",
        "10.",
        "10.123+10.123",
        "10.123 10.123 +",
        "10.+10.",
        "10. 10. +",
        "a",
        "a",
        "a+a",
        "a a +",
        "a*a+a",
        "a a * a +",
        "10+a",
        "10 a +",
        "a+a",
        "a a +",
        ".123",
        "0.123",
        ".",
        "0.",
        "123.",
        "123.",
        "123.+a",
        "123. a +",
        "10(10)",
        "10 10 *",
        "10(10)10",
        "10 10 * 10 *",
        "(10)10",
        "10 10 *",
        "10 (10)",
        "10 10 *",
        "10 10",
        "10 10 *",
        "10 + 10 10",
        "10 10 10 * +",
        "10.123 10",
        "10.123 10 *",
        "(10) 10",
        "10 10 *",
        "a a",
        "a a *",
        "aa",
        "a a *",
        "10a",
        "10 a *",
        "10 a",
        "10 a *",
        "10 (a)",
        "10 a *",
        "a (10)",
        "a 10 *",
        "10a10",
        "10 a * 10 *",
        "a10",
        "a 10 *",
        "10 a 10",
        "10 a * 10 *",
        "a 10",
        "a 10 *",
        "10 ^ 10 10",
        "10 10 ^ 10 *",
        "aaa",
        "a a * a *",
        "a a a",
        "a a * a *",
        "aa a",
        "a a * a *",
        "a aa",
        "a a * a *",
    };
    try testing.expect(success_cases.len % 2 == 0);

    var i: usize = 0;
    while (i < success_cases.len) : (i += 2) {
        const output = try infixToPostfix(success_cases[i], allocator);
        defer allocator.free(output);
        try testing.expectEqualSlices(u8, success_cases[i + 1], output);
    }
}

test "evaluate()" {
    const success_cases = .{
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
    };
    const success_case_numbers = [_]comptime_float{
        10,
        10,
        20,
        10,
        10,
        0,
        10,
        10,
        1,
        10,
        10,
        100,
        10,
        2,
        100,
        30,
        10,
        0,
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
        10,
        0,
        10,
        0,
        10,
        10,
        10,
        10,
        10,
        10,
    };
    try testing.expect(fail_case_numbers.len % 2 == 0);
    try testing.expect(fail_cases.len == fail_case_numbers.len / 2);
    inline for (0..success_cases.len) |i| {
        try testing.expectEqual(success_case_numbers[i * 3 + 2], try comptime evaluate(success_case_numbers[i * 3], success_case_numbers[i * 3 + 1], success_cases[i]));
    }
    inline for (0..fail_cases.len) |i| {
        if (evaluate(fail_case_numbers[i * 2], fail_case_numbers[i * 2 + 1], fail_cases[i])) |_| {
            return error.NotFail;
        } else |_| {}
    }
}

test "evaluatePostfix()" {
    const allocator = std.testing.allocator;
    const success_cases = [_][]const u8{
        "10 10 +",
        "10 10 -",
        "10 10 /",
        "10 2 3 3 * + + 10 -",
        "10. 10. +",
        "10.123 10.123 +",
        "10. 10.456 *",
        "a",
        "a",
        "a a +",
        "a a * a +",
        "10 a +",
        ".123",
        "123.",
        "123. a +",
    };
    const success_result_input = [_]f64{
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        10,
        10,
        10,
        10,
        0,
        // 0,
        0,
        0.456,
    };
    const success_results = [_]f64{
        20,
        0,
        1,
        11,
        20,
        20.246,
        104.56,
        0,
        10,
        20,
        110,
        20,
        0.123,
        // 0,
        123,
        123.456,
    };
    const fail_cases = [_][]const u8{
        "10 0 /",
        "10 0 %",
        "10 10 10 - /",
        "10 10 10 - %",
        "10 a /",
        "10 a %",
    };
    const fail_result_input = [_]f64{
        0,
        0,
        0,
        0,
        0,
        0,
    };
    for (success_cases, success_result_input, success_results) |case, input, result| {
        try testing.expectEqual(result, try evaluatePostfix(case, input, allocator));
    }
    for (fail_cases, fail_result_input) |case, input| {
        if (evaluatePostfix(case, input, allocator)) |_| {
            return error.NotFail;
        } else |_| {}
    }
}
