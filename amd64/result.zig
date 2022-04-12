const pdep = @import("intrinsic.zig").pdep;
const pext = @import("intrinsic.zig").pext;

fn res(i: u3, p: u8, n: u8) u8 {
    if (p & n != 0)
        return 0;
    var ret: u8 = 0;
    {
        var t = (n + (@as(u8, 2) << i)) & p;
        if (t != 0)
            ret |= t - (@as(u8, 2) << i);
    }
    {
        //var u = (n + (p << 1)) & (@as(u8, 1) << i);
        var t = ~n & ((@as(u8, 1) << i) - 1);
        t |= t >> 1;
        t |= t >> 2;
        t |= t >> 4;
        t = (t + 1) >> 1;
        if (t & p != 0)
            ret |= (@as(u8, 1) << i) - (t << 1);
    }
    return ret;
}

//https://github.com/ziglang/zig/issues/11312

extern fn @"llvm.assume"(bool) void;
fn intCast(comptime T: type, a: anytype) T {
    const b = @intCast(T, a);
    if (a != b) unreachable;
    @"llvm.assume"(a == b);
    return b;
}

pub fn result() [0x3000]u8 {
    var ret: [0x3000]u8 = undefined;
    const HELPER = @import("index.zig").HELPER;

    for (HELPER) |i, index| {
        const ind = intCast(u3, index);
        const mask = @import("mask.zig").MASK[ind][0];
        const range: u7 = switch (ind) {
            0, 7 => 64,
            2...5 => 32,
            1, 6 => continue,
        };

        var j: u64 = 0;
        while (j < range) : (j += 1) {
            var k: u64 = 0;
            while (k < range) : (k += 1) {
                const ii = i * 32 + j * 64 + k;
                const jj = intCast(u8, pdep(j, mask[0]));
                const kk = intCast(u8, pdep(k, mask[1]));

                ret[ii] = intCast(u8, pext(res(ind, jj, kk), mask[1]));
            }
        }
    }
    return ret;
}
