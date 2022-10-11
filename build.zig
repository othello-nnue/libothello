const std = @import("std");
const Pkg = std.build.Pkg;
const FS = std.build.FileSource;

const utils = Pkg{
    .name = "utils",
    .source = FS{ .path = "utils/main.zig" },
};
const bench = Pkg{
    .name = "bench",
    .source = FS{ .path = "zig-bench/bench.zig" },
};

// var target: std.zig.CrossTarget = undefined;
// var mode: std.builtin.Mode = undefined;

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const native_isa = @import("builtin").target.cpu.arch;
    const isa = target.cpu_arch orelse native_isa;

    const arch = Pkg{
        .name = "arch",
        .source = FS{
            .path = switch (isa) {
                .aarch64 => "arm64/main.zig",
                .x86_64 => "amd64/main.zig",
                else => unreachable,
            },
        },
        .dependencies = &.{utils},
    };
    const othello = Pkg{
        .name = "othello",
        .source = FS{ .path = "game/main.zig" },
        .dependencies = &.{ utils, arch },
    };
    const testing = Pkg{
        .name = "perft",
        .source = FS{ .path = "test/perft.zig" },
        .dependencies = &.{othello},
    };
    {
        const lib_step = b.step("lib", "Make library");
        {
            const lib = b.addStaticLibrary("othello", "game/ffi.zig");
            lib.strip = true;
            lib.single_threaded = true;
            lib.setTarget(target);
            lib.setBuildMode(std.builtin.Mode.ReleaseFast);
            lib.addPackage(othello);
            lib.addPackage(utils);
            const install = b.addInstallArtifact(lib);
            lib_step.dependOn(&install.step);
        }
        {
            const ver = b.version(0, 0, 0);
            const lib = b.addSharedLibrary("othello", "game/ffi.zig", ver);
            lib.strip = true;
            lib.single_threaded = true;
            lib.setTarget(target);
            lib.setBuildMode(std.builtin.Mode.ReleaseFast);
            lib.addPackage(othello);
            lib.addPackage(utils);
            const install = b.addInstallArtifact(lib);
            lib_step.dependOn(&install.step);
        }
    }
    {
        const exe = b.addExecutable("tui", "test/tui.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.addPackage(othello);

        const run_cmd = exe.run();

        const run_step = b.step("tui", "Run TUI app");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("bench", "test/bench.zig");
        exe.setTarget(target);
        exe.setBuildMode(std.builtin.Mode.ReleaseFast);
        exe.addPackage(othello);
        exe.addPackage(bench);
        exe.addPackage(testing);

        const run_cmd = exe.run();

        const run_step = b.step("bench", "Run benchmark tests");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("perf", "test/bench2.zig");
        exe.setTarget(target);
        exe.setBuildMode(std.builtin.Mode.ReleaseFast);
        exe.addPackage(othello);
        exe.addPackage(testing);

        // exe.install();
        const install = b.addInstallArtifact(exe);

        const run_step = b.step("perf", "Compile executable for perf");
        run_step.dependOn(&install.step);
    }
    const test_step = b.step("test", "Run library tests");
    for ([_]Pkg{ utils, arch, othello, testing }) |module| {
        var tests = b.addTestSource(module.source);
        tests.setTarget(target);
        tests.setBuildMode(mode);
        if (module.dependencies) |deps|
            for (deps) |dep|
                tests.addPackage(dep);
        test_step.dependOn(&tests.step);
    }
}
