//! Addon functions for the calculator
//! TODO:
//! - How to best implement and package function pointers for
//! the library?
//!     - We can't just pass them individually, and that would be
//! less extensible anyway requiring lots of boilerplate.
const std = @import("std");
const Cal = @import("CalculatorLib.zig");

// @sin, sinh, asin, asinh, @cos, cosh, acos, acosh, @tan, tanh, atan, atanh
// @sqrt, cbrt, abs, @exp
// @log, @log2, @log10
// @abs

// e, pi, tau

// sum, average, mode, median

pub fn registerKeywords(equation: *Cal.Equation) !void {
    try equation.addKeywords(&[_][]const u8{
        "sin",
        "sinh",
        "sum",
        "average",
        "median",
        "min",
        "max",
        "pi",
    }, &[_]Cal.KeywordInfo{
        .{ .F = .{ .l = 1, .ptr = sin } },
        .{ .F = .{ .l = 1, .ptr = sinh } },
        .{ .F = .{ .l = 0, .ptr = sum } },
        .{ .F = .{ .l = 0, .ptr = average } },
        .{ .F = .{ .l = 0, .ptr = median } },
        .{ .F = .{ .l = 0, .ptr = min } },
        .{ .F = .{ .l = 0, .ptr = max } },
        .{ .C = std.math.pi },
    });
}

// Trigonometry functions

fn sin(i: []f64) !f64 {
    std.debug.assert(i.len == 1);
    return std.math.sin(i[0]);
}

fn sinh(i: []f64) !f64 {
    std.debug.assert(i.len == 1);
    return std.math.sinh(i[0]);
}

// Statistics functions

fn sum(i: []f64) !f64 {
    var s: f64 = 0;
    for (i) |j| {
        s += j;
    }
    return s;
}

fn average(i: []f64) !f64 {
    return try sum(i) / @as(f64, @floatFromInt(i.len));
}

fn median(i: []f64) !f64 {
    std.sort.pdq(f64, i, {}, std.sort.asc(f64));
    return switch (i.len % 2 == 0) {
        true => return average(i[i.len / 2 - 1 .. i.len / 2 + 1]),
        false => return i[i.len / 2],
    };
}

fn min(i: []f64) !f64 {
    std.debug.assert(i.len > 0);
    var smallest = i[0];
    for (i) |j| {
        if (j < smallest) smallest = j;
    }
    return smallest;
}

fn max(i: []f64) !f64 {
    std.debug.assert(i.len > 0);
    var biggest = i[0];
    for (i) |j| {
        if (j > biggest) biggest = j;
    }
    return biggest;
}
