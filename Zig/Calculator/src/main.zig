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
        const infixEquation = try Calculator.InfixEquation.init(buffer[0..], stdout, stdin, allocator);

        result = infixEquation.evaluate(result) catch |err| switch (err) {
            Calculator.Error.DivisionByZero => continue,
            else => return err,
        };

        try Calculator.printResult(result, stdout);
    }
}
