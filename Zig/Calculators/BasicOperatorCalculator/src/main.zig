const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const CalculatorError = error{
    InvalidOperator,
    DivisionByZero,
    EmptyInput,
};

const operators = enum(u8) {
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

    try stdout.print("Enter the first number: ", .{});
    const input_1 = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n') orelse {
        try stdout.print("Cannot enter empty number", .{});
        return;
    };
    const number_1 = std.fmt.parseFloat(f64, input_1) catch {
        try stdout.print("Invalid number", .{});
        return;
    };

    try stdout.print("Enter the second number: ", .{});
    const input_2 = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n') orelse {
        try stdout.print("Cannot have no number", .{});
        return;
    };
    const number_2 = std.fmt.parseFloat(f64, input_2) catch {
        try stdout.print("Invalid number", .{});
        return;
    };

    const result = evaluate(number_1, number_2, try get_operator(buffer[0..])) catch |err| switch (err) {
        CalculatorError.DivisionByZero => {
            try stdout.print("Cannot divide by 0", .{});
            return;
        },
        CalculatorError.InvalidOperator => unreachable,
        CalculatorError.EmptyInput => unreachable,
    };

    try stdout.print("The result is {d:.3}", .{result});
}

fn get_operator(buffer: []u8) !u8 {
    var input: []u8 = undefined;
    while (true) {
        try stdout.print("Enter an operator: ", .{});
        input = try stdin.readUntilDelimiterOrEof(buffer, '\n') orelse {
            try stdout.print("Cannot have no operator", .{});
            continue;
        };
        if (input.len == 1) {
            _ = evaluate(1, 2, input[0]) catch {
                try stdout.print("That wasn't a valid operator\n", .{});
                continue;
            };
            return input[0];
        } else {
            try stdout.print("That wasn't a valid operator\n", .{});
        }
    }
}

fn evaluate(number_1: f64, number_2: f64, operator: u8) CalculatorError!f64 {
    return switch (@as(operators, @enumFromInt(operator))) {
        operators.addition => number_1 + number_2,
        operators.subtraction => number_1 - number_2,
        operators.division => if (number_2 == 0) CalculatorError.DivisionByZero else number_1 / number_2,
        operators.multiplication => number_1 * number_2,
        operators.exponentiation => std.math.pow(f64, number_1, number_2),
        operators.modulus => if (number_2 <= 0) CalculatorError.DivisionByZero else @mod(number_1, number_2),
        else => CalculatorError.InvalidOperator,
    };
}
