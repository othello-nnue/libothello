const expect = @import("std").testing.expect;
const print = @import("std").debug.print;
const game = @import("./main.zig");

test "init test" {
    const i = game.init();
    const j = game.moves(i);
    try expect(j == 17729692631040);
}

test "perft test" {
    comptime var i = 0;
    inline while (i < 12) : (i += 1) {
        try expect(perft(game.init(), i) == known_perft[i]);
        print("passed perft {}\n", .{i});
    }
}

fn perft(board: [2]u64, depth: usize) u64 {
    if (depth == 0) return 1;
    var moves = game.moves(board);
    if (moves == 0)
        return perft(.{ board[1], board[0] }, depth - 1);
    if (depth == 1) return @popCount(u64, moves);
    var sum: u64 = 0;
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        const t = game.move(board, i);
        //try expect(t != 0);
        moves ^= @as(u64, 1) << i;
        sum += perft(.{ board[1] ^ t, board[0] ^ t ^ (@as(u64, 1) << i) }, depth - 1);
    }
    return sum;
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
    390_216,
    3_005_288,
    24_571_284,
    212_258_800,
    1_939_886_636,
};
