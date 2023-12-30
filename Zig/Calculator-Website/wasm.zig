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

export fn evaluate(input: [*:0]const u8, previousInput: f64) Result {
    const allocator = std.heap.wasm_allocator;
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
    const infixEquation = equation.newInfixEquation(std.mem.span(input), null) catch |err| {
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
