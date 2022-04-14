const mul = @import("filter.zig").mul;
pub fn fill(a: u64, comptime dir: u6) u64 {
    var b = a;
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
        const std = @import("std");
        var i: u6 = 0;
        while (true) : (i += 1) {
            try std.testing.expectEqual(fill(@as(u64, 1) << i, x), fill2(i, j));
            if (~i == 0) break;
        }
    }
}
