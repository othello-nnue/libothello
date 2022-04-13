const MASK = @import("mask.zig").MASK;
const mul = @import("utils").mul;

fn flip_positive_scalar(board: [2]u64, place: u6) u64 {
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

fn flip_positive(board: [2]u64, place: u6) u64 {
    const t = @as(u64, 1) << place;
    const m = MASK[place];
    const high = @splat(4, @as(u64, 1) << 63);
    const zero = @splat(4, @as(u64, 0));
    const o = @splat(4, board[0]) & m;
    const u = (o ^ (o -% @splat(4, t))) & (m | high);
    const v = @splat(4, board[1]) & u & m;
    const w = @select(u64, u == v, u, zero);
    return @reduce(.Or, w);
}

pub fn flip(board: [2]u64, place: u6) u64 {
    // const a = [2]u64{ board[0], board[0] | (board[1] & 0x7FFF_FFFF_FFFF_FFFE) };
    // const b = [2]u64{ @bitReverse(u64, a[0]), @bitReverse(u64, a[1]) };
    const a = [2]u64{ board[0], board[0] | (board[1] & 0x7FFF_FFFF_FFFF_FFFE) };
    const b = [2]u64{ @bitReverse(u64, a[0]), @bitReverse(u64, a[1]) };

    return (flip_positive(a, place) |
        @bitReverse(u64, flip_positive(b, ~place))) &
        board[1];
}
