const Game = @import("othello");
const std = @import("std");
const panic = std.debug.panic;
const expectEqual = std.testing.expectEqual;

pub fn perft(board: Game, depth: usize) u64 {
    if (depth == 0) return 1;
    var moves = board.moves();
    if (moves == 0)
        return perft(board.pass(), depth - 1);
    if (depth == 1) return @popCount(moves);
    var sum: u64 = 0;
    while (moves != 0) {
        const i = @intCast(u6, @ctz(moves));

        moves &= moves - 1;
        sum += perft(board.move(i).?, depth - 1);
    }
    return sum;
}

pub fn print_avx512_usage() void {
    const print = std.debug.print;
    if (Game.has_avx512) {
        print("using AVX-512\n", .{});
    } else print("using default\n", .{});
}

//should change to property testing
fn check(board: Game, depth: usize) void {
    if (depth == 0) return;
    var moves = board.moves();

    var i: u6 = 0;
    var j: u64 = 1;
    while (j != 0) : ({
        j <<= 1;
        i +%= 1;
    }) {
        if ((board.board[0] | board.board[1]) & j != 0) continue;
        const t = board.move(i);
        if ((t == null) != (moves & j == 0))
            panic("{} {any} {}\n", .{ board, t, i });
        if (t) |u|
            check(u, depth - 1);
    }
    check(board.pass(), depth - 1);
}

test "perft test" {
    inline for (known_perft) |known, i|
        try expectEqual(perft(.{}, i), known);
}

test "check test" {
    //for minimal error case generation
    inline for (.{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }) |d|
        check(.{}, d);
}

//https://www.aartbik.com/strategy.php
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
    // 18429641748,
    // 184042084512,
};
