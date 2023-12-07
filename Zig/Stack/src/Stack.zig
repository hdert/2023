const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        data: std.ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            return Self{
                .data = std.ArrayList(T).init(allocator),
            };
        }

        pub fn free(self: Self) void {
            self.data.deinit();
        }

        pub fn push(self: *Self, item: T) !void {
            try self.data.append(item);
        }

        pub fn peek(self: Self) T {
            return self.data.getLast();
        }

        pub fn pop(self: *Self) T {
            return self.data.pop();
        }

        pub fn asSlice(self: Self) []T {
            return self.data.items;
        }

        pub fn len(self: Self) usize {
            return self.data.items.len;
        }
    };
}

test "Stack" {
    const allocator = std.testing.allocator;
    var stack = Stack(u64).init(allocator);
    defer stack.free();

    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{});
    try testing.expectEqual(stack.len(), 0);
    try stack.push(21);
    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{21});
    try testing.expectEqual(stack.len(), 1);
    try stack.push(19);
    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{ 21, 19 });
    try testing.expectEqual(stack.len(), 2);
    try testing.expectEqual(stack.peek(), 19);
    try testing.expectEqual(stack.pop(), 19);
    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{21});
    try testing.expectEqual(stack.len(), 1);
    try testing.expectEqual(stack.pop(), 21);
    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{});
    try testing.expectEqual(stack.len(), 0);
    try stack.push(21);
    try stack.push(22);
    try testing.expectEqualSlices(u64, stack.asSlice(), &[_]u64{ 21, 22 });
    try testing.expectEqual(stack.len(), 2);
}

test "No memleak" {
    const allocator = std.testing.allocator;
    var stack = Stack(u64).init(allocator);
    defer stack.free();

    for (0..300) |_| {
        try stack.push(1);
        try testing.expectEqual(stack.pop(), 1);
        try testing.expectEqual(stack.len(), 0);
    }

    for (0..300) |_| {
        try stack.push(1);
    }

    try testing.expectEqual(stack.len(), 300);
}
