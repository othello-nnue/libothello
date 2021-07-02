const math = @import("std").math;
const othello = @import("othello");
pub const evals = @import("./eval.zig");

pub fn simple(game: othello.Game, comptime eval: fn (othello.Game) i64) u6 {
    var moves = game.moves();
    var ret: u6 = 0;
    var min: i64 = 64; //should change
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = eval(game.move(i).?);
        if (j < min) {
            min = j;
            ret = i;
        }
    }
    return ret;
}

//alphabeta without tt
fn ab(game: othello.Game, comptime eval: fn (othello.Game) i64, alpha: i64, beta: i64, depth: u8) i64 {
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

pub fn absearch(game: othello.Game, comptime eval: fn (othello.Game) i64, depth: u8) u6 {
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

const Searcher = struct {
    history = [_]u16{0} ** (64 * 64),
    pub fn search() void {}
};

//countermove history

//pub fn minimax(game: othello.Game, comptime eval: fn (othello.Game) i64, depth : u64) i64 {
//minimax with memory
//mtdf with memory
//etc
