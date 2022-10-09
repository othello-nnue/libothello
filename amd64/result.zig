fn res(i: u3, p: u7, n: u7) u7 {
    const m = (@as(u7, 1) << i) - 1;
    if (p & (n >> 1 & ~m | (n << 1 & m)) != 0)
        return 0;

    return m & -%(@as(u7, 1) << (7 - @clz(~n & m)) & p) |
        ((n >> i) + 1 & p >> i << 1) -| 1 << i;
}

const gen_mask = [4]u5{ 0b00101, 0b01010, 0b01010, 0b10100 };

fn special(i: u2, p: u5, n: u5) u5 {
    const mask = gen_mask[i];
    if (i < 2) {
        return gen(mask, p, n, true) | gen(~mask, p, n, true);
    } else {
        return gen(mask, p, n, false) | gen(~mask, p, n, false);
    }
}
fn gen(mask: u5, p: u5, n: u5, is_up: bool) u5 {
    if (is_up) {
        const nn = @as(u6, n | ~mask) + 1;
        const nnn = @intCast(u5, (nn & -%nn) - 1);
        if (nnn & p & mask == 0) return 0;
        return nnn & mask;
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
                if (index < 8) {
                    const ind: u3 = @intCast(u3, index -| 1);
                    ret[ii] = @intCast(u6, res(ind, j, k));
                } else {
                    ret[ii] = special(@intCast(u2, index - 8), j, k);
                }
            }
        }
    }

    break :init ret;
};
