const MASK = @import("./mask.zig").MASK;
const mul = @import("utils").mul;

fn flip_positive(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    const t = @as(u64, 1) << place;
    for (MASK[place]) |m, i| {
        const o = (board[0] & m) >> 1;
        const u = (o ^ (o -% t)) & m;
        const v = u & board[1] & switch (i) {
            0 => mul(0xFF, 0x7E),
            1 => mul(0x7E, 0xFF),
            2, 3 => mul(0x7E, 0x7E),
            else => unreachable,
        };
        if (u == v) ret |= v;
    }
    return ret;
}

pub fn flip(board: [2]u64, place: u6) u64 {
    return flip_positive(board, place) | @bitReverse(u64, flip_positive([2]u64{ @bitReverse(u64, board[0]), @bitReverse(u64, board[1]) }, ~place));
}
