const std = @import("std");
const othello = @import("othello");
const bench = @import("bench");
const expect = @import("std").testing.expect;

fn perft(board: [2]u64, depth: usize) u64 {
    if (depth == 0) return 1;
    var moves = othello.moves(board);
    if (moves == 0)
        return perft(.{ board[1], board[0] }, depth - 1);
    if (depth == 1) return @popCount(u64, moves);
    var sum: u64 = 0;
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        const t = othello.move(board, i);

        moves ^= @as(u64, 1) << i;
        sum += perft(.{ board[1] ^ t, board[0] ^ t ^ (@as(u64, 1) << i) }, depth - 1);
    }
    return sum;
}

fn check(board: [2]u64, depth: usize) bool {
    if (depth == 0) return false;
    var moves = othello.moves(board);

    var i: u6 = 0;
    var j: u64 = 1;
    while (j != 0) : ({
        j <<= 1;
        i +%= 1;
    }) {
        if ((board[0] | board[1]) & j != 0) continue;
        const t = othello.move(board, i);

        if ((t == 0) != (moves & j == 0)) return true;
        if (t == 0) continue;
        if (check(.{ board[1] ^ t, board[0] ^ t ^ j }, depth - 1)) return true;
    }
    return check(.{ board[1], board[0] }, depth - 1);
}

test "init test" {
    const i = othello.init();
    const j = othello.moves(i);
    try expect(j == 17729692631040);
}

test "perft test" {
    inline for (known_perft) |known, i|
        try expect(perft(othello.init(), i) == known);
}

test "check test" {
    try expect(!check(othello.init(), 11));
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

pub fn main() anyerror!void {
    try bench.benchmark(struct {
        // The functions will be benchmarked with the following inputs.
        // If not present, then it is assumed that the functions
        // take no input.
        pub const args = [_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };

        // How many iterations to run each benchmark.
        // If not present then a default will be used.
        pub const min_iterations = 1;
        //pub const max_iterations = 10;

        pub fn perf(depth: usize) u64 {
            return perft(othello.init(), depth);
        }
    });
}
