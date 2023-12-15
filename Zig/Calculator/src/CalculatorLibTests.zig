const std = @import("std");
const Stack = @import("Stack");
const c = @import("CalculatorLib.zig");
const testing = std.testing;
const allocator = std.testing.allocator;

const testData = struct {
    infix_equations: []const []const u8,
    postfix_equations: []const []const u8,
    inputs: []const f64,
    results: []const f64,
};

const test_cases: testData = .{
    .infix_equations = &[_][]const u8{
        "10+10",                  "10 + 10",
        "    10+10 (20)",         "    10+10 *(20)",
        "10/10",                  "10 / (10)",
        "10*(10)",                "10 * ( 10 ) ",
        "10",                     "10.10+10.10",
        "10.999",                 "10.789 * ( 10.123 )",
        "10.123+10.123",          "10.",
        "10 + (10 / 2 * 3) + 10", "10 + a",
        "10.+10.",                "a",
        "a",                      "-a",
        "a+a",                    "a*a+a",
        "123.+a",                 ".123",
        ".",                      "123.",
        "10(10)",                 "10(10)10",
        "(10)10",                 "10 (10)",
        "10 10",                  "10 + 10 10",
        "10.123 10",              "(10) 10",
        "a a",                    "aa",
        "10a",                    "10 a",
        "10 (a)",                 "a (10)",
        "10a10",                  "a10",
        "10 a 10",                "a 10",
        "10 ^ 10 10",             "aaa",
        "a a a",                  "aa a",
        "a aa",                   "-10",
        "-.",                     "-a",
        "10-10",                  "0-10",
        "0+-10",                  "10*-10",
        "10--10",                 "10---10",
        "10+--10",                "10-.",
        "10--a",                  "-0",
        "-.0",                    "-0.",
        "--0",                    "--.",
        "--.0",                   "--0.0",
        "--0.",                   "-0.-0",
        ".-0",                    "0.0--0",
        ".--0",                   ". -. -0",
        ".--.",                   "--a",
        "-(10+5)",                "--(10+5)",
        "10-(10+5)",              "10+-(10+5)",
        "10 + (2 + 3 * 3) - 10",  "10. * 10.456",
    },
    .postfix_equations = &[_][]const u8{
        "10 10 +",              "10 10 +",
        "10 10 20 * +",         "10 10 20 * +",
        "10 10 /",              "10 10 /",
        "10 10 *",              "10 10 *",
        "10",                   "10.10 10.10 +",
        "10.999",               "10.789 10.123 *",
        "10.123 10.123 +",      "10.",
        "10 10 2 / 3 * + 10 +", "10 a +",
        "10. 10. +",            "a",
        "a",                    "-a",
        "a a +",                "a a * a +",
        "123. a +",             "0.123",
        "0.",                   "123.",
        "10 10 *",              "10 10 * 10 *",
        "10 10 *",              "10 10 *",
        "10 10 *",              "10 10 10 * +",
        "10.123 10 *",          "10 10 *",
        "a a *",                "a a *",
        "10 a *",               "10 a *",
        "10 a *",               "a 10 *",
        "10 a * 10 *",          "a 10 *",
        "10 a * 10 *",          "a 10 *",
        "10 10 ^ 10 *",         "a a * a *",
        "a a * a *",            "a a * a *",
        "a a * a *",            "-10",
        "-0.",                  "-a",
        "10 10 -",              "0 10 -",
        "0 -10 +",              "10 -10 *",
        "10 -10 -",             "10 10 -",
        "10 10 +",              "10 0. -",
        "10 -a -",              "-0",
        "-0.0",                 "-0.",
        "0",                    "0.",
        "0.0",                  "0.0",
        "0.",                   "-0. 0 -",
        "0. 0 -",               "0.0 -0 -",
        "0. -0 -",              "0. 0. - 0 -",
        "0. -0. -",             "a",
        "-1 10 5 + *",          "10 5 +",
        "10 10 5 + -",          "10 -1 10 5 + * +",
        "10 2 3 3 * + + 10 -",  "10. 10.456 *",
    },
    .inputs = &[_]f64{
        0,  0,  0,  0,  0,   0,  0,     0,
        0,  0,  0,  0,  0,   0,  0,     10,
        0,  0,  10, 10, 10,  10, 0.456, 0,
        0,  0,  0,  0,  0,   0,  0,     0,
        0,  0,  10, 10, 10,  10, 10,    10,
        10, 10, 10, 10, 0,   10, 10,    10,
        10, 0,  0,  10, 0,   0,  0,     0,
        0,  0,  0,  0,  -10, 0,  0,     0,
        0,  0,  0,  0,  0,   0,  0,     0,
        0,  0,  0,  10, 0,   0,  0,     0,
        0,  0,
    },
    .results = &[_]f64{
        20,                 20,     210,     210,
        1,                  1,      100,     100,
        10,                 20.2,   10.999,  109.217047,
        20.246,             10,     35,      20,
        20,                 0,      10,      -10,
        20,                 110,    123.456, 0.123,
        0,                  123,    100,     1000,
        100,                100,    100,     110,
        101.22999999999999, 100,    100,     100,
        100,                100,    100,     100,
        1000,               100,    1000,    100,
        100000000000,       1000,   1000,    1000,
        1000,               -10,    0,       -10,
        0,                  -10,    -10,     -100,
        20,                 0,      20,      10,
        0,                  0,      0,       0,
        0,                  0,      0,       0,
        0,                  0,      0,       0,
        0,                  0,      0,       10,
        -15,                15,     -5,      -5,
        11,                 104.56,
    },
};

test "InfixEquation.fromString" {
    const fail_cases = .{
        "10++10",  "10(*10)",
        "10(10*)", "10*",
        "10(10)*", "()",
        "10()",    "21 + 2 ) * ( 5 / 6",
        "10.789.", "10.789.123",
        "10..",    "",
        "-",       "-0.-",
        "10-",     "--",
        ".-",      ". -. -",
        null,      "1(",
        "(",
    };
    inline for (test_cases.infix_equations) |case| {
        try testing.expectEqualSlices(u8, case, (try c.InfixEquation.fromString(case, null, allocator)).data);
    }
    inline for (fail_cases) |case| {
        if (c.InfixEquation.fromString(case, null, allocator)) |_| {
            return error.NotFail;
        } else |_| {}
    }
}

test "InfixEquation.toPostfixEquation" {
    for (test_cases.infix_equations, test_cases.postfix_equations) |infix, postfix| {
        const infixEquation = try c.InfixEquation.fromString(infix, null, allocator);
        const postfixEquation = try infixEquation.toPostfixEquation();
        defer postfixEquation.free();
        try testing.expectEqualSlices(u8, postfix, postfixEquation.data);
    }
}

test "PostfixEquation.fromInfixEquation" {
    for (test_cases.infix_equations, test_cases.postfix_equations) |infix, postfix| {
        const infixEquation = try c.InfixEquation.fromString(infix, null, allocator);
        const postfixEquation = try c.PostfixEquation.fromInfixEquation(infixEquation);
        defer postfixEquation.free();
        try testing.expectEqualSlices(u8, postfix, postfixEquation.data);
    }
}

test "InfixEquation.evaluate" {
    for (test_cases.infix_equations, test_cases.inputs, test_cases.results) |infix, input, result| {
        const infix_equation = c.InfixEquation{
            .data = infix,
            .allocator = allocator,
        };
        const output = try infix_equation.evaluate(input);
        testing.expectEqual(result, output) catch |err| {
            std.debug.print("Expected: {d}\nGot: {d}\nCase: {s}\nPrevious Answer: {d}\n", .{
                result,
                output,
                infix,
                input,
            });
            return err;
        };
    }
}

test "PostfixEquation.evaluate" {
    const fail_cases = [_][]const u8{
        "10 0 /",       "10 0 %",
        "10 10 10 - /", "10 10 10 - %",
        "10 a /",       "10 a %",
        "--10",
    };
    const fail_result_input = [_]f64{
        0, 0,
        0, 0,
        0, 0,
        0,
    };
    for (test_cases.postfix_equations, test_cases.inputs, test_cases.results) |postfix, input, result| {
        const postfix_equation = c.PostfixEquation{
            .data = postfix,
            .allocator = allocator,
        };
        const output = try postfix_equation.evaluate(input);
        testing.expectEqual(result, output) catch |err| {
            std.debug.print("Expected: {d}\nGot: {d}\nCase: {s}\nPrevious Answer: {d}\n", .{
                result,
                output,
                postfix,
                input,
            });
            return err;
        };
    }
    for (fail_cases, fail_result_input) |case, input| {
        const postfix_equation = c.PostfixEquation{
            .data = case,
            .allocator = allocator,
        };
        const result = postfix_equation.evaluate(input);
        if (result) |_| {
            return error.NotFail;
        } else |_| {}
    }
}
