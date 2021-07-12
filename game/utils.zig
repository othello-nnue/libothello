// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;
extern fn @"llvm.x86.bmi.pext.64"(u64, u64) u64;

pub inline fn pext(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pext.64"(a, b);
}

pub inline fn pdep(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pdep.64"(a, b);
}

pub inline fn mul(x: u8, y: u8) u64 {
    return @byteSwap(u64, (@as(u64, x) *% 0x8040_2010_0804_0201 & 0x8080_8080_8080_8080) >> 7) * y;
}

inline fn mul2(x: u8, y: u8) u64 {
    return pdep(x, 0x0101_0101_0101_0101) * y;
}

const std = @import("std");
test "check mul" {
    var i: u8 = 0;
    while (true) : (i += 1) {
        try std.testing.expectEqual(mul(i, 1), mul2(i, 1));
        if (i == 0xFF) break;
    }
}

pub inline fn make_array(comptime T: type, comptime func: fn (u6) T) [64]T {
    @setEvalBranchQuota(10000);
    var ret: [64]T = undefined;
    for (ret) |*m, i|
        m.* = func(@intCast(u6, i));
    return ret;
}

pub fn lut_type(comptime t: type) type {
    comptime var x = @typeInfo(t).Fn.return_type.?;
    inline for (@typeInfo(t).Fn.args) |arg| {
        const arg_type = @typeInfo(arg.arg_type.?).Int;
        std.debug.assert(arg_type.signedness == .unsigned);
        x = [1 << arg_type.bits]x;
    }
    return x;
}

pub fn fill(a: u64, comptime dir: u6) u64 {
    var b = a;
    comptime var x = switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1 => 0xFEFE_FEFE_FEFE_FEFE,
        7 => 0x7F7F_7F7F_7F7F_7F7F,
        else => unreachable,
    };
    comptime var y = switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1 => 0x7F7F_7F7F_7F7F_7F7F,
        7 => 0xFEFE_FEFE_FEFE_FEFE,
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        b |= (b << d & x) | (b >> d & y);
        x &= x << d;
        y &= y >> d;
    }
    return b;
}

fn fill2(pos: u6, dir: u2) u64 {
    const t = @as(u64, 1) << pos;
    var r =
        switch (dir) {
        0 => mul(0x01, 0xFF),
        1 => mul(0xFF, 0x01),
        2 => mul(0x01, 0x80),
        3 => mul(0x01, 0x01),
    };
    while (r & t == 0)
        r = switch (dir) {
            0 => r << 8,
            1 => r << 1,
            2 => r >> 1 & mul(0xFF, 0x7F) | r << 8,
            3 => r << 1 & mul(0xFF, 0xFE) | r << 8,
        };
    return r;
}

test "fill" {
    inline for (.{ 1, 8, 9, 7 }) |x, j| {
        var i: u6 = 0;
        while (true) : (i += 1) {
            try std.testing.expectEqual(fill(@as(u64, 1) << i, x), fill2(i, j));
            if (~i == 0) break;
        }
    }
}
