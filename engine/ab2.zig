//https://github.com/ziglang/zig/issues/5675

const math = @import("std").math;
const Game = @import("othello");
const eval = @import("./eval.zig");
const Self = @This();

depth: u8,
comptime eval: fn (Game) i64 = eval.mobility,

//alphabeta without tt
fn ab(game: Game, comptime ev: fn (Game) i64, alpha: i64, beta: i64, depth: u8) i64 {
    if (depth == 0) return ev(game);
    var moves = game.moves();
    if (moves == 0) return ~ab(game.pass(), ev, ~beta, ~alpha, depth - 1);
    var a = alpha;

    var max: i64 = math.minInt(i64); //should change
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~ab(game.move(i).?, ev, ~beta, ~a, depth - 1);
        if (j > max) max = j;
        if (j > a) a = j;
        if (j >= beta) break;
    }
    return max;
}

pub fn move(self: Self, game: Game) u6 {
    var moves = game.moves();
    if (moves == 0) return 0;
    var alpha: i64 = math.minInt(i64);
    const beta: i64 = math.maxInt(i64);
    var ret: u6 = undefined;

    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~ab(game.move(i).?, self.eval, ~beta, ~alpha, self.depth);
        if (j > alpha) {
            alpha = j;
            ret = i;
        }
    }
    return ret;
}
