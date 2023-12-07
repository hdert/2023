const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const CalculatorError = error{
    InvalidOperator,
    DivisionByZero,
    EmptyInput,
    SequentialOperators,
    EndsWithOperator,
};

const Operator = enum(u8) {
    addition = '+',
    subtraction = '-',
    division = '/',
    multiplication = '*',
    exponentiation = '^',
    modulus = '%',
    _,
};

pub fn main() !void {
    var buffer: [100]u8 = undefined;
    while (true) {
        const input = try getInput(buffer[0..]);

        const result = try evaluateString(input);

        try stdout.print("The result is {d:.3}\n", .{result});
    }
}

fn getInput(buffer: []u8) ![]u8 {
    while (true) {
        try stdout.print("Enter your equation: ", .{});
        const input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
        if (validateInput(input)) |result| {
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
                CalculatorError.DivisionByZero => unreachable,
                else => return err,
            }
        }
    }
}

fn validateInput(input: ?[]u8) ![]u8 {
    var isOperator = true;
    var result: []u8 = undefined;
    if (@import("builtin").os.tag == .windows) {
        result = std.mem.trimRight(u8, input orelse return CalculatorError.EmptyInput, "\r");
    } else {
        result = input orelse return CalculatorError.EmptyInput;
    }
    if (result.len == 0) return CalculatorError.EmptyInput;
    for (result) |char| {
        switch (char) {
            ' ' => continue,
            '0'...'9' => {
                isOperator = false;
                continue;
            },
            else => {
                if (isOperator) {
                    return CalculatorError.SequentialOperators;
                }
                _ = evaluate(1, 2, char) catch {
                    return CalculatorError.InvalidOperator;
                };
                isOperator = true;
            },
        }
    }
    if (isOperator) {
        return CalculatorError.EndsWithOperator;
    }
    return result;
}

fn evaluateString(input: []u8) !f64 {
    var i: usize = 0;
    var result = getNumber(input, &i);
    while (i < input.len) {
        const operator = getOperator(input, &i);
        result = evaluate(result, getNumber(input, &i), operator) catch |err| switch (err) {
            CalculatorError.DivisionByZero => {
                try stdout.print("You cannot divide by 0\n", .{});
                return err;
            },
            else => unreachable,
        };
    }
    return result;
}

fn getNumber(input: []u8, i: *usize) f64 {
    var number: f64 = 0;
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            ' ' => continue,
            '0'...'9' => {
                number *= 10;
                number += @floatFromInt(input[i.*] - '0');
            },
            else => break,
        }
    }
    return number;
}

fn getOperator(input: []u8, i: *usize) u8 {
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            ' ' => continue,
            else => {
                defer i.* += 1;
                return input[i.*];
            },
        }
    }
    return input[i.*];
}

fn evaluate(number_1: f64, number_2: f64, operator: u8) CalculatorError!f64 {
    return switch (@as(Operator, @enumFromInt(operator))) {
        Operator.addition => number_1 + number_2,
        Operator.subtraction => number_1 - number_2,
        Operator.division => if (number_2 == 0) CalculatorError.DivisionByZero else number_1 / number_2,
        Operator.multiplication => number_1 * number_2,
        Operator.exponentiation => std.math.pow(f64, number_1, number_2),
        Operator.modulus => if (number_2 <= 0) CalculatorError.DivisionByZero else @mod(number_1, number_2),
        _ => CalculatorError.InvalidOperator,
    };
}
