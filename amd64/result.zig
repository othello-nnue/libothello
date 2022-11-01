fn gen(mask: u6, p: u6, n: u6, is_up: bool) u6 {
    const nn = ~n & mask;
    const nnn = mask & ~if (is_up)
        -%(nn & -%nn)
    else
        @as(u7, 63) >> @clz(nn);
    if (nnn & p == 0) return 0;
    return @intCast(u6, nnn);
}

pub const RESULT = init: {
    @setEvalBranchQuota(1000000);
    var ret: [0x4000]u6 = undefined;

    for (@import("index.zig").HELPER) |i, index| {
        const range = ret[0..switch (index) {
            0, 7 => 64,
            else => 32,
        }];

        const m = @truncate(u8, 0x544A8A85_3F1F0F07030100FF >> (8 * index));
        for (range) |_, j| {
            for (range) |_, k|
                ret[(i + 2 * j) * 32 + k] =
                    gen(@truncate(u5, ~m), j, k, m & 64 == 0) //
                | gen(@truncate(u6, m), j, k, m & 128 != 0);
        }
    }

    break :init ret;
};
