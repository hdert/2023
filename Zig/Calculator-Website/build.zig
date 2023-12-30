const std = @import("std");

pub fn build(b: *std.Build) void {
    const calculator = b.dependency("calculator", .{});

    // WASM library

    const lib = b.addSharedLibrary(.{
        .name = "Calculator",
        .root_source_file = .{ .path = "wasm.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
        .optimize = .ReleaseFast,
    });
    lib.addModule("Calculator", calculator.module("Calculator"));
    lib.addModule("Addons", calculator.module("Addons"));
    const lib_output = b.addInstallArtifact(lib, .{
        .dest_dir = .{
            .override = .{
                .custom = "Calculator",
            },
        },
    });
    b.getInstallStep().dependOn(&lib_output.step);
}
