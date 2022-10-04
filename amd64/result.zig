fn res(i: u3, p: u8, n: u8) u8 {
    const m = (@as(u8, 1) << i) - 1;
    if (p & (n >> 1 & ~m | (n << 1 & m)) != 0)
        return 0;

    return m & -%(@as(u8, 1) << @intCast(u3, 8 - @clz(~n & m)) & p) |
        (((n >> i) + 1 & p >> i << 1) -| 1 << i);
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
