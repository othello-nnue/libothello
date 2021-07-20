const std = @import("std");
const Pkg = std.build.Pkg;
const F = std.build.FileSource;

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const isa = target.cpu_arch orelse std.Target.current.cpu.arch;

    const utils = Pkg{
        .name = "utils",
        .path = F{ .path = "game/utils.zig" },
    };
    const arch = Pkg{
        .name = "arch",
        .path = F{
            .path = switch (isa) {
                .aarch64 => "game/arm64/main.zig",
                .x86_64 => "game/amd64/main.zig",
                else => unreachable,
            },
        },
        .dependencies = &.{utils},
    };
    const othello = Pkg{
        .name = "othello",
        .path = F{ .path = "game/main.zig" },
        .dependencies = &.{ utils, arch },
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
        const lib = b.addStaticLibrary("othello", "game/ffi.zig");
        lib.setTarget(target);
        lib.setBuildMode(mode);
        lib.addPackage(othello);
        lib.install();
    }
    {
        const ver = b.version(0, 0, 0);
        const lib = b.addSharedLibrary("othello", "game/ffi.zig", ver);
        lib.setTarget(target);
        lib.setBuildMode(std.builtin.Mode.ReleaseFast);
        lib.addPackage(othello);
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
        const exe = b.addExecutable("elo", "perf/elo.zig");
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

        const run_step = b.step("elo", "Run regression tests");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("stability", "perf/stability.zig");
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

        const run_step = b.step("stability", "Run stability tests");
        run_step.dependOn(&run_cmd.step);
    }
    {
        const exe = b.addExecutable("perf", "perf/bench.zig");
        exe.setTarget(target);
        exe.setBuildMode(std.builtin.Mode.ReleaseFast);
        exe.addPackage(othello);
        exe.addPackage(bench);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("bench", "Run benchmark tests");
        run_step.dependOn(&run_cmd.step);
    }
    const test_step = b.step("test", "Run library tests");
    {
        var tests = b.addTest("game/utils.zig");
        tests.setTarget(target);
        tests.setBuildMode(std.builtin.Mode.ReleaseSafe);
        test_step.dependOn(&tests.step);
    }
    if (isa == .x86_64) {
        var tests = b.addTest("game/amd64/test.zig");
        tests.setTarget(target);
        tests.setBuildMode(std.builtin.Mode.ReleaseSafe);
        tests.addPackage(utils);
        test_step.dependOn(&tests.step);
    }
    {
        var tests = b.addTest("perf/test.zig");
        tests.setTarget(target);
        //tests.setBuildMode(std.builtin.Mode.ReleaseSafe);
        tests.setBuildMode(mode);
        tests.addPackage(othello);
        test_step.dependOn(&tests.step);
    }
}
