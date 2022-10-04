const pdep = @import("intrinsic.zig").pdep;
const pext = @import("intrinsic.zig").pext;

fn res(i: u3, p: u8, n: u8) u8 {
    if ((p << 1) & n & (@as(u8, 0xFE) << i) != 0 or p & (n << 1) & ((@as(u8, 1) << i) - 1) != 0)
        return 0;

    var ret: u8 = 0;
    {
        var t = ((n >> i) + 1) & ((p >> i) << 1);
        if (t != 0)
            ret |= (t - 1) << i;
    }
    {
        //var u = (n + (p << 1)) & (@as(u8, 1) << i);
        var t = ~n & ((@as(u8, 1) << i) - 1);
        t = @as(u8, 1) << @intCast(u3, 8 - @clz(t));
        if (t & p != 0)
            ret |= (@as(u8, 1) << i) - t;
    }
    return ret;
}

pub fn result() [0x3000]u6 {
    var ret: [0x3000]u6 = undefined;
    const HELPER = @import("index.zig").HELPER;

    for (HELPER) |i, index| {
        const range: u7 = switch (index) {
            0, 7 => 64,
            else => 32,
            1, 6 => continue,
        };
        const ind: u3 = switch (index) {
            0 => 0,
            7 => 6,
            else => @intCast(u3, index - 1),
        };

        var j: u64 = 0;
        while (j < range) : (j += 1) {
            var k: u64 = 0;
            while (k < range) : (k += 1) {
                const ii = @as(u64, i) * 32 + j * 64 + k;
                const jj = @intCast(u6, j);
                const kk = @intCast(u6, k);

                ret[ii] = @intCast(u6, res(ind, jj, kk));
            }
        }
    }
    return ret;
}
