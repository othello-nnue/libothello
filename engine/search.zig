const math = @import("std").math;
const Game = @import("othello");
pub const evals = @import("./eval.zig");

//alphabeta without tt
fn ab(game: Game, comptime eval: fn (Game) i64, alpha: i64, beta: i64, depth: u8) i64 {
    if (depth == 0) return eval(game);
    var moves = game.moves();
    if (moves == 0) return ~ab(game.pass(), eval, ~beta, ~alpha, depth - 1);
    var a = alpha;

    var max: i64 = math.minInt(i64); //should change
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~ab(game.move(i).?, eval, ~beta, ~a, depth - 1);
        if (j > max) max = j;
        if (j > a) a = j;
        if (j >= beta) break;
    }
    return max;
}

pub fn absearch(game: Game, comptime eval: fn (Game) i64, depth: u8) u6 {
    if (depth == 0) return 0;
    var moves = game.moves();
    if (moves == 0) return 0;
    var alpha: i64 = math.minInt(i64);
    const beta: i64 = math.maxInt(i64);
    var ret: u6 = undefined;

    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~ab(game.move(i).?, eval, ~beta, ~alpha, depth - 1);
        if (j > alpha) {
            alpha = j;
            ret = i;
        }
    }
    return ret;
}

//todo : iterative deepening

const Searcher = struct {
    history: u16[64][64],
    pub fn search() void {}
};

//countermove history

//pub fn minimax(game: Game, comptime eval: fn (Game) i64, depth : u64) i64 {
//minimax with memory
//mtdf with memory
//etc
