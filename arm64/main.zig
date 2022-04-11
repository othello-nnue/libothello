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

fn flip_positive2(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    const t = @as(u64, 1) << place;
    const m: @Vector(u64, 4) = MASK[place];
    const n: @Vector(u64, 4) = .{
        mul(0xFF, 0x7E),
        mul(0x7E, 0xFF),
        mul(0x7E, 0x7E),
        mul(0x7E, 0x7E),
    };
    const o = (@splat(4, board[0]) & m) >> 1;
    const u = (o ^ (o -% @splat(4, t))) & m;
    const v = u & @splat(4, board[1]) & n;
    const w = @select(u64, u == v, u, @splat(4, @as(u64, 0)));
    return @reduce(.Or, w);
}

pub fn flip(board: [2]u64, place: u6) u64 {
    const reversed = [2]u64{ @bitReverse(u64, board[0]), @bitReverse(u64, board[1]) };
    return flip_positive(board, place) |
        @bitReverse(u64, flip_positive(reversed, ~place));
}
