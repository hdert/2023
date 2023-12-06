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
    var result = getNumber(buffer[0..]) catch return;

    while (true) {
        const operator = try getOperator(buffer[0..]);
        const number = getNumber(buffer[0..]) catch |err| switch (err) {
            CalculatorError.EmptyInput => break,
            else => return err,
        };
        result = evaluate(result, number, operator) catch |err| switch (err) {
            CalculatorError.DivisionByZero => {
                try stdout.print("Cannot divide by zero\n", .{});
                return;
            },
            else => unreachable,
        };
    }
    try stdout.print("The result is {d:.3}\n", .{result});
}

fn getNumber(buffer: []u8) !f64 {
    while (true) {
        try stdout.print("Number: ", .{});
        const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n') orelse {
            return CalculatorError.EmptyInput;
        };
        if (user_input.len == 0) {
            return CalculatorError.EmptyInput;
        }
        const number = std.fmt.parseFloat(f64, user_input) catch {
            try stdout.print("Invalid number\n", .{});
            continue;
        };
        return number;
    }
}

fn getOperator(buffer: []u8) !u8 {
    var input: []u8 = undefined;
    while (true) {
        try stdout.print("Enter an operator: ", .{});
        input = try stdin.readUntilDelimiterOrEof(buffer, '\n') orelse {
            try stdout.print("Cannot have no operator\n", .{});
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
