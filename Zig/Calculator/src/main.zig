const std = @import("std");
const Calculator = @import("CalculatorLib.zig");
const Io = @import("Io.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) std.debug.print("Memory leak", .{});
    var result: f64 = 0;
    var buffer: [100]u8 = undefined;
    const io = Io.init(stdout, stdin);
    var equation = try Calculator.Equation.init(
        allocator,
        null,
        null,
    );
    defer equation.free();
    try Io.registerKeywords(&equation);

    // try stdout.print("Use the keyword 'a' to substitute the previous answer\n", .{});
    try io.defaultHelp();
    while (true) {
        try equation.registerPreviousAnswer(result);
        const infixEquation = io.getInputFromUser(
            equation,
            buffer[0..],
        ) catch |err| switch (err) {
            Io.Error.Help => continue,
            Io.Error.Exit => return,
            else => return err,
        };

        result = infixEquation.evaluate(result) catch |err| switch (err) {
            Calculator.Error.DivisionByZero => continue,
            else => return err,
        };

        try io.printResult(result);
    }
}
