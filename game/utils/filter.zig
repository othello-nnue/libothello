// make square filter
pub inline fn mul(comptime x: u8, comptime y: u8) u64 {
    return @byteSwap(u64, (@as(u64, x) *% 0x8040_2010_0804_0201 & 0x8080_8080_8080_8080) >> 7) * y;
}

fn mul2(x: u8, y: u8) u64 {
    const pdep = @import("intrinsic.zig").pdep;
    return pdep(x, 0x0101_0101_0101_0101) * y;
}

const std = @import("std");
test "check mul" {
    comptime var i: u8 = 0;
    inline while (true) : (i += 1) {
        try std.testing.expectEqual(mul(i, 1), mul2(i, 1));
        if (i == 0xFF) break;
    }
}
