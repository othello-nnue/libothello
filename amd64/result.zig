fn res(i: u3, p: u8, n: u8) u8 {
    const m = (@as(u8, 1) << i) - 1;
    if (p & (n >> 1 & ~m | (n << 1 & m)) != 0)
        return 0;

    return m & -%(@as(u8, 1) << @intCast(u3, 8 - @clz(~n & m)) & p) |
        (((n >> i) + 1 & p >> i << 1) -| 1 << i);
}

pub const RESULT = init: {
    @setEvalBranchQuota(1000000);
    var ret: [0x3000]u6 = undefined;

    for (@import("index.zig").HELPER) |i, index| {
        const range: u7 = switch (index) {
            0, 7 => 64,
            else => 32,
        };
        const ind: u3 = @intCast(u3, index -| 1);

        var j: u8 = 0;
        while (j < range) : (j += 1) {
            var k: u8 = 0;
            while (k < range) : (k += 1) {
                const ii = @as(u64, i + 2 * j) * 32 + k;

                ret[ii] = @intCast(u6, res(ind, j, k));
            }
        }
    }

    break :init ret;
};
