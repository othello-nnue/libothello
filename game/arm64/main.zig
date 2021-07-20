const MASK = @import("./mask.zig").MASK;

fn flip_positive(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    const t = @as(u64, 1) << place;
    for (MASK2[place]) |mask| {
        const o = (board[0] & mask[0]) >> 1;
        const u = (o ^ (o -% t)) & mask[0];
        const v = u & board[1] & mask[1];
        if (u == v) ret |= v;
    }

    return ret;
}

pub fn flip(board: [2]u64, place: u6) u64 {
    return flip_positive(board, place) | @bitReverse(u64, flip_positive([2]u64{ @bitReverse(u64, board[0]), @bitReverse(u64, board[1]) }, ~place));
}
