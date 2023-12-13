const std = @import("std");

const targets: []const std.zig.CrossTarget = &.{
    .{ .cpu_arch = .x86_64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const stack = b.addModule("Stack", .{ .source_file = .{ .path = "../Stack/src/Stack.zig" } });

    for (targets) |t| {
        const exe = b.addExecutable(.{
            .name = "Calculator",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = t,
            .optimize = .ReleaseSafe,
        });
        exe.addModule("Stack", stack);

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });
        b.getInstallStep().dependOn(&target_output.step);
    }

    const exe = b.addExecutable(.{
        .name = "Calculator",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("Stack", stack);
    const target_output = b.addInstallArtifact(exe, .{
        .dest_dir = .{
            .override = .{
                .custom = try target.zigTriple(b.allocator),
            },
        },
    });
    b.getInstallStep().dependOn(&target_output.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/CalculatorLibTests.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.addModule("Stack", stack);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
