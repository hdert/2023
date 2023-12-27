const std = @import("std");

pub fn build(b: *std.Build) void {
    const stack = b.addModule("Stack", .{ .source_file = .{ .path = "../Stack/src/Stack.zig" } });

    // WASM library

    const lib = b.addSharedLibrary(.{
        .name = "Calculator",
        .root_source_file = .{ .path = "wasm.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
        .optimize = .ReleaseFast,
    });
    lib.addModule("Stack", stack);
    const CalculatorLib = b.addModule(
        "CalculatorLib.zig",
        .{
            .source_file = .{ .path = "../Calculator/src/CalculatorLib.zig" },
            .dependencies = &[_]std.build.ModuleDependency{
                .{ .name = "Stack", .module = stack },
            },
        },
    );
    lib.addModule("CalculatorLib.zig", CalculatorLib);
    const addons = b.addModule(
        "addons.zig",
        .{ .source_file = .{ .path = "../Calculator/src/addons.zig" }, .dependencies = &[_]std.build.ModuleDependency{
            .{ .name = "CalculatorLib.zig", .module = CalculatorLib },
        } },
    );
    lib.addModule("addons.zig", addons);
    const lib_output = b.addInstallArtifact(lib, .{
        .dest_dir = .{
            .override = .{
                .custom = "Calculator",
            },
        },
    });
    b.getInstallStep().dependOn(&lib_output.step);
}
