const std = @import("std");
const othello = @import("othello");
const bench = @import("bench");

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
