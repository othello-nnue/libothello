const othello = @import("othello");
const expect = @import("std").testing.expect;

pub fn perft(board: othello.Game, depth: usize) u64 {
    if (depth == 0) return 1;
    var moves = board.moves();
    if (moves == 0)
        return perft(board.pass(), depth - 1);
    if (depth == 1) return @popCount(u64, moves);
    var sum: u64 = 0;
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));

        moves ^= @as(u64, 1) << i;
        sum += perft(board.move(i).?, depth - 1);
    }
    return sum;
}

fn check(board: othello.Game, depth: usize) bool {
    if (depth == 0) return false;
    var moves = board.moves();

    var i: u6 = 0;
    var j: u64 = 1;
    while (j != 0) : ({
        j <<= 1;
        i +%= 1;
    }) {
        if ((board.board[0] | board.board[1]) & j != 0) continue;
        const t = board.move(i);

        if ((t == null) != (moves & j == 0)) return true;
        if (t == null) continue;
        if (check(t.?, depth - 1)) return true;
    }
    return check(board.pass(), depth - 1);
}

test "init test" {
    const i = othello.init();
    const j = othello.moves(i);
    try expect(j == 0x0000_1020_0408_0000);
}

test "size test" {
    try expect(@sizeOf(othello.Game) == 16);
}

// https://github.com/ziglang/zig/issues/3696
test "assign test" {
    var g = othello.Game{};
    g = g.pass();
    try expect(g.board[0] != g.board[1]);
}

test "perft test" {
    inline for (known_perft) |known, i|
        try expect(perft(.{}, i) == known);
}

test "check test" {
    try expect(!check(.{}, 11));
}

const known_perft = .{
    1,
    4,
    12,
    56,
    244,
    1396,
    8200,
    55092,
    390216,
    3005288,
    24571284,
    212258800,
    1939886636,
};
