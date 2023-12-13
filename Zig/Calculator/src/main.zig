const std = @import("std");
const Calculator = @import("CalculatorLib.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) std.debug.print("Memory leak", .{});
    var result: f64 = 0;
    var buffer: [100]u8 = undefined;

    try stdout.print("Use the keyword 'a' to substitute the previous answer\n", .{});
    while (true) {
        const input = try Calculator.getInput(buffer[0..], stdout, stdin);

        const output = try Calculator.infixToPostfix(input, allocator);
        defer allocator.free(output);

        result = Calculator.evaluatePostfix(output, result, allocator) catch |err| switch (err) {
            Calculator.Error.DivisionByZero => {
                try stdout.print("Cannot divide by zero\n", .{});
                continue;
            },
            else => return err,
        };

        // try stdout.print("The result is {any}\n", .{result});
        try Calculator.printResult(result, stdout);
    }
}
