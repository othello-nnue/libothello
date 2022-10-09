fn res(i: u3, p: u7, n: u7) u7 {
    const m = (@as(u7, 1) << i) - 1;
    if (p & (n >> 1 & ~m | (n << 1 & m)) != 0)
        return 0;

    return m & -%(@as(u7, 1) << (7 - @clz(~n & m)) & p) |
        ((n >> i) + 1 & p >> i << 1) -| 1 << i;
}

const gen_mask = [2]u5{ 0b00101, 0b01010 };

fn special(i: u2, p: u5, n: u5) u5 {
    const mask = gen_mask[@truncate(u1, @popCount(i))];
    if (i < 2) {
        return gen(mask, p, n, true) | gen(~mask, p, n, true);
    } else {
        return gen(mask, p, n, false) | gen(~mask, p, n, false);
    }
}
fn gen(mask: u5, p: u5, n: u5, is_up: bool) u5 {
    if (is_up) {
        const nn = (n | ~mask) + 1;
        return ((nn & (p & mask -| 1)) -| 1) & mask;
    } else {
        const nn = @truncate(u5, @as(u6, 1) << (5 - @clz(~n & mask)));
        if (p & mask & -%nn != 0) {
            return -%nn & mask;
        } else return 0;
    }
}

pub const RESULT = init: {
    @setEvalBranchQuota(1000000);
    var ret: [0x4000]u6 = undefined;

    for (@import("index.zig").HELPER) |i, index| {
        const range: u7 = switch (index) {
            0, 7 => 64,
            else => 32,
        };

        var j: u7 = 0;
        while (j < range) : (j += 1) {
            var k: u7 = 0;
            while (k < range) : (k += 1) {
                const ii = @as(u64, i + 2 * j) * 32 + k;
                if (i < 8) {
                    const ind: u3 = @intCast(u3, index -| 1);
                    ret[ii] = @intCast(u6, res(ind, j, k));
                } else {
                    ret[ii] = gen(@intCast(u2, i - 8, j, k));
                }
            }
        }
    }

    break :init ret;
};
