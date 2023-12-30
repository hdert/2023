const std = @import("std");
const Cal = @import("Calculator");
const Addons = @import("Addons");

pub const Result = extern struct {
    result: Return,
    tag: bool,
};

pub const Return = extern union {
    success: f64,
    fail: u16,
};

extern fn print(u32) void;

export fn allocateUint8(length: u32) [*]const u8 {
    const slice = std.heap.wasm_allocator.alloc(u8, length) catch
        @panic("failed to allocate memory");
    return slice.ptr;
}

export fn evaluate_quick(input: [*:0]const u8, previousInput: f64) f64 {
    const allocator = std.heap.wasm_allocator;
    const slice = std.mem.span(input);
    defer allocator.free(slice);

    var equation = Cal.Equation.init(
        allocator,
        null,
        null,
    ) catch return 0;
    defer equation.free();
    Addons.registerKeywords(&equation) catch return 0;

    equation.registerPreviousAnswer(previousInput) catch return 0;
    return (equation.newInfixEquation(
        slice,
        null,
    ) catch return 0)
        .evaluate() catch return 0;
}

export fn evaluate(input: [*:0]const u8, previousInput: f64) Result {
    const allocator = std.heap.wasm_allocator;
    const slice = std.mem.span(input);
    defer allocator.free(slice);
    var equation = Cal.Equation.init(
        allocator,
        null,
        null,
    ) catch |err| {
        return Result{
            .result = .{ .fail = @intFromError(err) },
            .tag = false,
        };
    };
    defer equation.free();
    Addons.registerKeywords(&equation) catch |err| {
        return Result{
            .result = .{ .fail = @intFromError(err) },
            .tag = false,
        };
    };
    equation.registerPreviousAnswer(previousInput) catch |err| {
        return Result{
            .result = .{ .fail = @intFromError(err) },
            .tag = false,
        };
    };
    const infixEquation = equation.newInfixEquation(slice, null) catch |err| {
        return Result{
            .result = .{ .fail = @intFromError(err) },
            .tag = false,
        };
    };
    const result = infixEquation.evaluate() catch |err| {
        return Result{
            .result = .{ .fail = @intFromError(err) },
            .tag = false,
        };
    };
    return Result{
        .result = .{ .success = result },
        .tag = true,
    };
}
