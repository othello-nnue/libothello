const mul = @import("filter.zig").mul;

/// perform flood fill in specified direction
/// @param board bitboard
/// @param dir direction specified by shift length (1, 7, 8, 9)
/// @return filled board
pub fn fill(board: u64, comptime dir: u6) u64 {
    var r = board;
    comptime var x = switch (@mod(dir, 8)) {
        0 => mul(0xFF, 0xFF),
        1 => mul(0xFF, 0xFE),
        7 => mul(0xFF, 0x7F),
        else => unreachable,
    };
    comptime var y = switch (@mod(dir, 8)) {
        0 => mul(0xFF, 0xFF),
        1 => mul(0xFF, 0x7F),
        7 => mul(0xFF, 0xFE),
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        r |= (r << d & x) | (r >> d & y);
        x &= x << d;
        y &= y >> d;
    }
    return r;
}

// generate a ray `r` and shift until it intersects with `t`
fn fill2(pos: u6, dir: u2) u64 {
    const t = @as(u64, 1) << pos;
    var r = switch (dir) {
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

const expectEqual = @import("std").testing.expectEqual;
test "fill" {
    inline for (.{ 1, 8, 9, 7 }) |x, j| {
        var i: u6 = 0;
        while (true) : (i += 1) {
            try expectEqual(fill(@as(u64, 1) << i, x), fill2(i, j));
            if (~i == 0) break;
        }
    }
}
