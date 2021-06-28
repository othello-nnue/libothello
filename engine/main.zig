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

//pub fn minimax(game: othello.Game, comptime eval: fn (othello.Game) i64, depth : u64) i64 {
//minimax with memory
//mtdf with memory
//etc
