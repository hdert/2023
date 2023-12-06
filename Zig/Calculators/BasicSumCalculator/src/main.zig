const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var buffer: [100]u8 = undefined;
    try stdout.print("Type a number: ", .{});
    const number_1 = block: {
        if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |user_input| {
            break :block std.fmt.parseInt(i64, user_input, 10) catch 0;
        } else {
            break :block 0;
        }
    };

    try stdout.print("Type a second number: ", .{});
    const number_2 = block: {
        if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |user_input| {
            break :block std.fmt.parseInt(i64, user_input, 10) catch 0;
        } else {
            break :block 0;
        }
    };

    try stdout.print("The sum is {d}\n", .{number_1 + number_2});
}
