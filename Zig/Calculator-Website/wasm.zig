const std = @import("std");
const Cal = @import("Calculator");
const Addons = @import("Addons");
const allocator = std.heap.wasm_allocator;

extern fn print([*:0]const u8, usize) void;

export fn alloc(length: usize) ?[*]u8 {
    return if (allocator.alloc(u8, length)) |slice|
        slice.ptr
    else |_|
        null;
}

export fn evaluate(input: [*:0]const u8, previousInput: f64) f64 {
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
