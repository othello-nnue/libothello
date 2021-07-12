// https://github.com/ziglang/zig/issues/2291

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
        std.debug.print("{}\n", .{i});
        try std.testing.expectEqual(mul(i, 1), mul2(i, 1));
        if (i == 0xFF) break;
    }
}
