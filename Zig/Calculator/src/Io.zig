//! All calculator and library helper functions that deal with IO.
//! This module is entirely untested, due to it's nature, so extra
//! scrutiny is advised and required.
const std = @import("std");
const Cal = @import("CalculatorLib.zig");

pub const Error = error{
    Help,
    Exit,
};

const Self = @This();

stdout: std.fs.File.Writer,
stdin: std.fs.File.Reader,

pub fn init(stdout: std.fs.File.Writer, stdin: std.fs.File.Reader) Self {
    return Self{
        .stdout = stdout,
        .stdin = stdin,
    };
}

pub fn registerKeywords(equation: *Cal.Equation) !void {
    try equation.addKeywords(&[_][]const u8{
        "h",
        "help",
        "exit",
        "leave",
        "return",
        "quit",
        "q",
        "close",
    }, &[_]Cal.KeywordInfo{
        .{ .R = Error.Help },
        .{ .R = Error.Help },
        .{ .R = Error.Exit },
        .{ .R = Error.Exit },
        .{ .R = Error.Exit },
        .{ .R = Error.Exit },
        .{ .R = Error.Exit },
        .{ .R = Error.Exit },
    });
}

pub fn printResult(self: Self, result: f64) !void {
    const abs_result = if (result < 0) -result else result;
    const small = abs_result < std.math.pow(f64, 10, -9);
    const big = abs_result > std.math.pow(f64, 10, 9);
    if (!(big or small) or result == 0) {
        try self.stdout.print("The result is {d}\n", .{result});
    } else {
        try self.stdout.print("The result is {e}\n", .{result});
    }
}

/// The caller ensures equation.stdout is not null
pub fn getInputFromUser(
    self: Self,
    equation: Cal.Equation,
    buffer: []u8,
) !Cal.InfixEquation {
    while (true) {
        try self.stdout.writeAll("Enter your equation: ");
        const user_input = self.stdin.readUntilDelimiterOrEof(buffer, '\n') catch |err| switch (err) {
            error.StreamTooLong => {
                try self.stdout.writeAll("Input too large\n");
                try self.stdin.skipUntilDelimiterOrEof('\n'); // Try to flush stdin
                continue;
            },
            else => return err,
        };
        if (equation.newInfixEquation(user_input, self)) |result| {
            return result;
        } else |err| switch (err) {
            Error.Help => {
                try self.defaultHelp();
                return err;
            },
            Error.Exit => return err,
            else => if (!Cal.isError(err)) return err,
        }
    }
}

pub fn handleError(
    self: Self,
    err: anyerror,
    location: ?[3]usize,
    equation: ?[]const u8,
) !void {
    const stdout = self.stdout;
    const E = Cal.Error;
    switch (err) {
        E.InvalidOperator, E.Comma => try stdout.writeAll(
            "You have entered an invalid operator\n",
        ),
        E.InvalidKeyword => try stdout.writeAll(
            "You have entered an invalid keyword\n",
        ),
        E.DivisionByZero => try stdout.writeAll(
            "Cannot divide by zero\n",
        ),
        E.EmptyInput => try stdout.writeAll(
            "You cannot have an empty input\n",
        ),
        E.SequentialOperators => try stdout.writeAll(
            "You cannot enter sequential operators\n",
        ),
        E.EndsWithOperator => try stdout.writeAll(
            "You cannot finish with an operator\n",
        ),
        E.StartsWithOperator => try stdout.writeAll(
            "You cannot start with an operator\n",
        ),
        E.ParenEmptyInput => try stdout.writeAll(
            "You cannot have an empty parenthesis block\n",
        ),
        E.ParenStartsWithOperator => try stdout.writeAll(
            "You cannot start a parentheses block with an operator\n",
        ),
        E.ParenEndsWithOperator => try stdout.writeAll(
            "You cannot end a parentheses block with an operator\n",
        ),
        E.ParenMismatched, E.ParenMismatchedClose => try stdout.writeAll(
            "Mismatched parentheses!\n",
        ),
        E.InvalidFloat => try stdout.writeAll(
            "You cannot have more than one period in a floating point number\n",
        ),
        E.FnUnexpectedArgSize => try stdout.writeAll(
            "You haven't passed the correct number of arguments to this function\n",
        ),
        E.FnArgBoundsViolated => try stdout.writeAll(
            "Your arguments aren't within the range that this function expected\n",
        ),
        E.FnArgInvalid => try stdout.writeAll(
            "Your argument to this function is invalid\n",
        ),
        else => return err,
    }
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
}

pub fn defaultHelp(self: Self) !void {
    try self.stdout.writeAll(
        \\General Purpose Calculator, written in Zig by Justin, © 2023-2024
        \\This calculator supports the standard order of operations, with the
        \\exception of the ordering of powers '^', these are ordered left-to-
        \\-right, unlike most calculators which order them right-to-left.
        \\
        \\You can exit this calculator with the keywords 'exit', 'quit', 
        \\'leave', 'close', or 'q'.
        \\You can call this help menu with the keywords 'h' or 'help'.
        \\This calculator supports using the previous answer with the keywords
        \\'a', 'ans', or 'answer'.
        \\
        \\The operators in this calculator are:
        \\    Brackets/Parentheses: '(', ')'
        \\    Exponentiation/Powers: '^'
        \\    Division: '/'
        \\    Multiplication: '*'
        \\    Addition: '+'
        \\    Subtraction: '-'
        \\
        \\This calculator supports functions which can be called like this:
        \\    'cos(2pi)'
        \\    'sum(2.5pi, -5, 40)'
        \\
        \\For a full list of functions, please consult the user manual.
        \\
    );
}
