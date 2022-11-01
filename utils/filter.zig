/// get outer product
/// mul(1<<i,1<<j) = 1<<(8*i+j)
/// @param x row signal/column vector
/// @param y column signal/row vector
/// @return outer product matrix
// better implementation when clmul lands
pub inline fn mul(comptime x: u8, comptime y: u8) u64 {
    return comptime @byteSwap((@as(u64, x) *% 0x8040_2010_0804_0201 & 0x8080_8080_8080_8080) >> 7) * y;
}

// fn mul2(x: u8, y: u8) u64 {
//     const pdep = @import("intrinsic.zig").pdep;
//     return pdep(x, 0x0101_0101_0101_0101) * y;
// }

fn mul3(x: u8, y: u8) u64 {
    comptime var i = 0;
    var res: u64 = 0;
    inline while (i < 8) : (i += 1) {
        if (x & (1 << i) != 0)
            res |= @as(u64, y) << (i * 8);
    }
    return res;
}

const expectEqual = @import("std").testing.expectEqual;
test "check mul" {
    comptime var i = 0;
    inline while (true) : (i += 1) {
        try expectEqual(mul(i, 1), mul3(i, 1));
        if (i == 0xFF) break;
    }
}
