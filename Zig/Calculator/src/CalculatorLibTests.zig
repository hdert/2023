const std = @import("std");
const Stack = @import("Stack");
const c = @import("CalculatorLib.zig");
const testing = std.testing;
const allocator = std.testing.allocator;

test "Operator.precedence() validity" {
    const success_cases = .{
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
        '(',
        ')',
    };
    const fail_cases = .{
        'a',
        '1',
        '0',
        'w',
        '9',
        '&',
        '.',
        'a',
    };
    inline for (success_cases) |case| {
        _ = try @as(c.Operator, @enumFromInt(case)).precedence();
    }
    inline for (fail_cases) |case| {
        const result = @as(c.Operator, @enumFromInt(case)).precedence();
        try testing.expectError(c.Error.InvalidOperator, result);
    }
}

const test_cases = [_][5][]u8{
    .{"10+10"},       .{"10 + 10"},   .{"    10+10 (20)"},      .{"10/10"},
    .{"10 / (10)"},   .{"10*(10)"},   .{"10 * ( 10 ) "},        .{"10"},
    .{"10.10+10.10"}, .{"10.999"},    .{"10.789 * ( 10.123 )"}, .{"10 + a"},
    .{"a"},           .{"a+a"},       .{".123"},                .{"."},
    .{"123."},        .{"10(10)"},    .{"10(10)10"},            .{"(10)10"},
    .{"10 (10)"},     .{"10 10"},     .{"10 + 10 10"},          .{"10.123 10"},
    .{"(10) 10"},     .{"a a"},       .{"aa"},                  .{"10a"},
    .{"10 a"},        .{"10 (a)"},    .{"a (10)"},              .{"10a10"},
    .{"a10"},         .{"10 a 10"},   .{"a 10"},                .{"10 ^ 10 10"},
    .{"aaa"},         .{"a a a"},     .{"aa a"},                .{"a aa"},
    .{"-10"},         .{"-."},        .{"-a"},                  .{"10-10"},
    .{"0-10"},        .{"0+-10"},     .{"10*-10"},              .{"10--10"},
    .{"10---10"},     .{"10+--10"},   .{"10-."},                .{"10--a"},
    .{"-0"},          .{"-.0"},       .{"-0."},                 .{"--0"},
    .{"--."},         .{"--.0"},      .{"--0.0"},               .{"--0."},
    .{"-0.-0"},       .{".-0"},       .{"0.0--0"},              .{".--0"},
    .{". -. -0"},     .{".--."},      .{"--a"},                 .{"-(10+5)"},
    .{"--(10+5)"},    .{"10-(10+5)"}, .{"10+-(10+5)"},
};

test "validateInput()" {
    const success_cases = .{
        "10+10",       "10 + 10",   "    10+10 (20)",      "10/10",
        "10 / (10)",   "10*(10)",   "10 * ( 10 ) ",        "10",
        "10.10+10.10", "10.999",    "10.789 * ( 10.123 )", "10 + a",
        "a",           "a+a",       ".123",                ".",
        "123.",        "10(10)",    "10(10)10",            "(10)10",
        "10 (10)",     "10 10",     "10 + 10 10",          "10.123 10",
        "(10) 10",     "a a",       "aa",                  "10a",
        "10 a",        "10 (a)",    "a (10)",              "10a10",
        "a10",         "10 a 10",   "a 10",                "10 ^ 10 10",
        "aaa",         "a a a",     "aa a",                "a aa",
        "-10",         "-.",        "-a",                  "10-10",
        "0-10",        "0+-10",     "10*-10",              "10--10",
        "10---10",     "10+--10",   "10-.",                "10--a",
        "-0",          "-.0",       "-0.",                 "--0",
        "--.",         "--.0",      "--0.0",               "--0.",
        "-0.-0",       ".-0",       "0.0--0",              ".--0",
        ". -. -0",     ".--.",      "--a",                 "-(10+5)",
        "--(10+5)",    "10-(10+5)", "10+-(10+5)",
    };
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
        null,
    };
    inline for (success_cases) |case| {
        try testing.expectEqualSlices(u8, case, try c.validateInput(case));
    }
    inline for (fail_cases) |case| {
        if (c.validateInput(case)) |_| {
            return error.NotFail;
        } else |_| {}
    }
}

test "infixToPostfix()" {
    const success_cases = [_][]const u8{
        "10+10",                  "10 10 +",
        "10 + 10",                "10 10 +",
        "    10+10 *(20)",        "10 10 20 * +",
        "    10+10 (20)",         "10 10 20 * +",
        "10/10",                  "10 10 /",
        "10 / (10)",              "10 10 /",
        "10*(10)",                "10 10 *",
        "10 * ( 10 ) ",           "10 10 *",
        "10",                     "10",
        "10 + (10 / 2 * 3) + 10", "10 10 2 / 3 * + 10 +",
        "10.",                    "10.",
        "10.123+10.123",          "10.123 10.123 +",
        "10.+10.",                "10. 10. +",
        "a",                      "a",
        "a+a",                    "a a +",
        "a*a+a",                  "a a * a +",
        "10+a",                   "10 a +",
        "a+a",                    "a a +",
        ".123",                   "0.123",
        ".",                      "0.",
        "123.",                   "123.",
        "123.+a",                 "123. a +",
        "10(10)",                 "10 10 *",
        "10(10)10",               "10 10 * 10 *",
        "(10)10",                 "10 10 *",
        "10 (10)",                "10 10 *",
        "10 10",                  "10 10 *",
        "10 + 10 10",             "10 10 10 * +",
        "10.123 10",              "10.123 10 *",
        "(10) 10",                "10 10 *",
        "a a",                    "a a *",
        "aa",                     "a a *",
        "10a",                    "10 a *",
        "10 a",                   "10 a *",
        "10 (a)",                 "10 a *",
        "a (10)",                 "a 10 *",
        "10a10",                  "10 a * 10 *",
        "a10",                    "a 10 *",
        "10 a 10",                "10 a * 10 *",
        "a 10",                   "a 10 *",
        "10 ^ 10 10",             "10 10 ^ 10 *",
        "aaa",                    "a a * a *",
        "a a a",                  "a a * a *",
        "aa a",                   "a a * a *",
        "a aa",                   "a a * a *",
        "-10",                    "-10",
        "-.",                     "-0.",
        "-a",                     "-a",
        "10-10",                  "10 10 -",
        "0-10",                   "0 10 -",
        "0+-10",                  "0 -10 +",
        "10*-10",                 "10 -10 *",
        "10--10",                 "10 -10 -",
        "10---10",                "10 10 -",
        "10+--10",                "10 10 +",
        "10-.",                   "10 0. -",
        "10--a",                  "10 -a -",
        "-0",                     "-0",
        "-.0",                    "-0.0",
        "-0.",                    "-0.",
        "--0",                    "0",
        "--.",                    "0.",
        "--.0",                   "0.0",
        "--0.0",                  "0.0",
        "--0.",                   "0.",
        "-0.-0",                  "-0. 0 -",
        ".-0",                    "0. 0 -",
        "0.0--0",                 "0.0 -0 -",
        ".--0",                   "0. -0 -",
        ". -. -0",                "0. 0. - 0 -",
        ".--.",                   "0. -0. -",
        "--a",                    "a",
        "-(10+5)",                "-1 10 5 + *",
        "--(10+5)",               "10 5 +",
        "10-(10+5)",              "10 10 5 + -",
        "10+-(10+5)",             "10 -1 10 5 + * +",
    };
    try testing.expect(success_cases.len % 2 == 0);

    var i: usize = 0;
    while (i < success_cases.len) : (i += 2) {
        const output = try c.infixToPostfix(success_cases[i], allocator);
        defer allocator.free(output);
        try testing.expectEqualSlices(u8, success_cases[i + 1], output);
    }
}

test "evaluate()" {
    const success_cases = .{
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
    };
    const success_case_numbers = [_]comptime_float{
        10, 10, 20,
        10, 10, 0,
        10, 10, 1,
        10, 10, 100,
        10, 2,  100,
        30, 10, 0,
    };
    try testing.expect(success_case_numbers.len % 3 == 0);
    try testing.expect(success_cases.len == success_case_numbers.len / 3);
    const fail_cases = .{
        '/',
        '%',
        'a',
        '&',
        '1',
    };

    const fail_case_numbers = .{
        10, 0,
        10, 0,
        10, 10,
        10, 10,
        10, 10,
    };
    try testing.expect(fail_case_numbers.len % 2 == 0);
    try testing.expect(fail_cases.len == fail_case_numbers.len / 2);
    inline for (0..success_cases.len) |i| {
        const result = try comptime c.evaluate(success_case_numbers[i * 3], success_case_numbers[i * 3 + 1], success_cases[i]);
        try testing.expectEqual(success_case_numbers[i * 3 + 2], result);
    }
    inline for (0..fail_cases.len) |i| {
        if (c.evaluate(fail_case_numbers[i * 2], fail_case_numbers[i * 2 + 1], fail_cases[i])) |_| {
            return error.NotFail;
        } else |_| {}
    }
}

test "evaluatePostfix()" {
    const success_cases = [_][]const u8{
        "10 10 +",             "10 10 -",   "10 10 /",
        "10 2 3 3 * + + 10 -", "10. 10. +", "10.123 10.123 +",
        "10. 10.456 *",        "a",         "a",
        "a a +",               "a a * a +", "10 a +",
        ".123",                "123.",      "123. a +",
        "-10",                 "-0.",       "-a",
        "10 10 -",             "0 10 -",    "0 -10 +",
        "10 -10 *",            "10 -10 -",  "10 10 -",
        "10 10 +",             "10 0. -",   "10 -a -",
        "-0",                  "-0.0",      "-0.",
        "0",                   "0.",        "0.0",
        "0.0",                 "0.",        "-0. 0 -",
        "0. 0 -",              "0.0 -0 -",  "0. -0 -",
        "0. 0. - 0 -",         "0. -0. -",  "a",
        "-1 10 5 + *",         "10 5 +",    "10 10 5 + -",
        "10 -1 10 5 + * +",
    };
    const success_result_input = [_]f64{
        0,  0,  0,
        0,  0,  0,
        0,  0,  10,
        10, 10, 10,
        0,  0,  0.456,
        0,  0,  10,
        0,  0,  0,
        0,  0,  0,
        0,  0,  -10,
        0,  0,  0,
        0,  0,  0,
        0,  0,  0,
        0,  0,  0,
        0,  0,  10,
        0,  0,  0,
        0,
    };
    const success_results = [_]f64{
        20,     0,   1,
        11,     20,  20.246,
        104.56, 0,   10,
        20,     110, 20,
        0.123,  123, 123.456,
        -10,    0,   -10,
        0,      -10, -10,
        -100,   20,  0,
        20,     10,  0,
        0,      0,   0,
        0,      0,   0,
        0,      0,   0,
        0,      0,   0,
        0,      0,   10,
        -15,    15,  -5,
        -5,
    };
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
    for (success_cases, success_result_input, success_results, 0..) |case, input, result, i| {
        const eval_result = try c.evaluatePostfix(case, input, allocator);
        testing.expectEqual(result, eval_result) catch |err| {
            std.debug.print("Expected: {d}\nCase: {s}\nPrevious Answer: {d}\nNumber: {d}\n", .{ result, case, input, i });
            return err;
        };
    }
    for (fail_cases, fail_result_input) |case, input| {
        if (c.evaluatePostfix(case, input, allocator)) |_| {
            return error.NotFail;
        } else |_| {}
    }
}
