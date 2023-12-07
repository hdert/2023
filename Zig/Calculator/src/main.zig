const std = @import("std");
const Calculator = @import("CalculatorLib.zig");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) unreachable;
    var result: f64 = 0;
    var buffer: [100]u8 = undefined;

    try stdout.print("Use the keyword 'a' to substitute the previous answer\n", .{});
    while (true) {
        const input = try Calculator.getInput(buffer[0..]);

        const output = try Calculator.infixToPostfix(input, allocator);

        result = Calculator.evaluatePostfix(output, result, allocator) catch |err| switch (err) {
            Calculator.CalculatorError.DivisionByZero => continue,
            else => return err,
        };

        try stdout.print("The result is {d:.6}\n", .{result});
    }
}
