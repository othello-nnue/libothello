const expect = @import("std").testing.expect;
const print = @import("std").debug.print;
const game = @import("./game.zig");
const lut = @import("./lut.zig");

test "init test" {
    const i = game.init();
    const j = game.moves(i);
    try expect(@popCount(u64, j) == 4);
}

test "perft test" {
    comptime var i = 0;

    inline while (i < 11) : (i += 1) {
        try expect(perft(game.init(), i) == known_perft[i]);
    }
}

fn perft(board: [2]u64, depth: usize) u64 {
    if (depth == 0) {
        return 1;
    } else {
        var moves = game.moves(board);
        if (moves == 0) {
            return perft(.{ board[1], board[0] }, depth - 1);
        } else {
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
    }
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
