//! All calculator and library helper functions that deal with IO.
//! This module is entirely untested, due to it's nature, so extra
//! scrutiny is advised and required.
const std = @import("std");
const Cal = @import("CalculatorLib.zig");

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

pub fn getEquationFromUser(
    buffer: []u8,
    stdout: std.fs.File.Writer,
    stdin: std.fs.File.Reader,
    allocator: std.mem.Allocator,
) !Cal.InfixEquation {
    while (true) {
        try stdout.writeAll("Enter your equation: ");
        const user_input = try stdin.readUntilDelimiterOrEof(buffer, '\n');
        if (Cal.InfixEquation.fromString(user_input, stdout, allocator)) |result| {
            return result;
        } else |err| {
            if (!Cal.isError(err)) return err;
        }
    }
}

pub fn printError(
    err: anyerror,
    stdout: std.fs.File.Writer,
    location: ?[3]usize,
    equation: ?[]const u8,
) !void {
    if (location) |l| {
        switch (err) {
            Cal.Error.DivisionByZero, Cal.Error.EmptyInput => {},
            else => {
                std.debug.assert(l[1] >= l[0]);
                std.debug.assert(equation != null);
                try stdout.print("{?s}\n", .{equation});
                for (l[0]) |_| try stdout.writeAll("-");
                for (l[1] - l[0]) |_| try stdout.writeAll("^");
                for (l[2] - l[1]) |_| try stdout.writeAll("-");
                try stdout.writeAll("\n");
            },
        }
    }
    switch (err) {
        Cal.Error.InvalidOperator => try stdout.writeAll(
            "You have entered an invalid operator\n",
        ),
        Cal.Error.InvalidKeyword => try stdout.writeAll(
            "You have entered an invalid keyword\n",
        ),
        Cal.Error.DivisionByZero => try stdout.writeAll(
            "Cannot divide by zero\n",
        ),
        Cal.Error.EmptyInput => try stdout.writeAll(
            "You cannot have an empty input\n",
        ),
        Cal.Error.SequentialOperators => try stdout.writeAll(
            "You cannot enter sequential operators\n",
        ),
        Cal.Error.EndsWithOperator => try stdout.writeAll(
            "You cannot finish with an operator\n",
        ),
        Cal.Error.StartsWithOperator => try stdout.writeAll(
            "You cannot start with an operator\n",
        ),
        Cal.Error.ParenEmptyInput => try stdout.writeAll(
            "You cannot have an empty parenthesis block\n",
        ),
        Cal.Error.ParenStartsWithOperator => try stdout.writeAll(
            "You cannot start a parentheses block with an operator\n",
        ),
        Cal.Error.ParenEndsWithOperator => try stdout.writeAll(
            "You cannot end a parentheses block with an operator\n",
        ),
        Cal.Error.ParenMismatched => try stdout.writeAll(
            "Mismatched parentheses!\n",
        ),
        Cal.Error.InvalidFloat => try stdout.writeAll(
            "You cannot have more than one period in a floating point number\n",
        ),
        else => return err,
    }
}
