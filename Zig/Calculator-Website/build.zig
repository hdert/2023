const std = @import("std");

pub fn build(b: *std.Build) void {
    const calculator = b.dependency("calculator", .{});

    // WASM library

    const exe = b.addExecutable(.{
        .name = "Calculator",
        .root_source_file = .{ .path = "wasm.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
        .optimize = .ReleaseFast,
    });
    exe.addModule("Calculator", calculator.module("Calculator"));
    exe.addModule("Addons", calculator.module("Addons"));

    exe.entry = .disabled;
    exe.rdynamic = true;

    const output = b.addInstallArtifact(exe, .{
        .dest_dir = .{
            .override = .{
                .custom = "../",
            },
        },
    });
    b.getInstallStep().dependOn(&output.step);
}
