const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var total: f64 = 0;

    try stdout.print("Type any amount of numbers you want the sum of, finishing with a blank line:\n", .{});

    while (true) {
        const user_input = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n') orelse break;
        if (std.fmt.parseFloat(f64, user_input)) |number| {
            total += number;
        } else |_| {
            break;
        }
    }

    try stdout.print("The sum is {d}\n", .{total});
}
