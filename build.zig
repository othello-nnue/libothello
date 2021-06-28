const std = @import("std");
const Pkg = std.build.Pkg;
const F = std.build.FileSource;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const othello = Pkg{
        .name = "othello",
        .path = F{ .path = "game/main.zig" },
    };
    const bench = Pkg{
        .name = "bench",
        .path = F{ .path = "zig-bench/bench.zig" },
    };
    const engine = Pkg{
        .name = "engine",
        .path = F{ .path = "engine/main.zig" },
        .dependencies = &.{othello},
    };

    {
        const lib = b.addStaticLibrary("othello", "game/main.zig");
        lib.setTarget(target);
        lib.setBuildMode(mode);
        lib.install();
    }
    {
        const lib = b.addStaticLibrary("engine", "engine/main.zig");
        lib.addPackage(othello);
        lib.setTarget(target);
        lib.setBuildMode(mode);
        lib.install();
    }
    {
        const exe = b.addExecutable("tui", "tui/main.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);

        exe.addPackage(othello);
        exe.addPackage(engine);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("perf", "perf/main.zig");
        exe.setTarget(target);
        exe.setBuildMode(std.builtin.Mode.ReleaseFast);

        exe.addPackage(othello);
        exe.addPackage(bench);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("bench", "Run benchmark tests");
        run_step.dependOn(&run_cmd.step);
    }
    {
        var tests = b.addTest("perf/main.zig");
        tests.setTarget(target);
        tests.setBuildMode(std.builtin.Mode.ReleaseSafe);

        tests.addPackage(othello);
        tests.addPackage(bench);

        const test_step = b.step("test", "Run library tests");
        test_step.dependOn(&tests.step);
    }
}
