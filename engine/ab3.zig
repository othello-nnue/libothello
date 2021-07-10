//https://github.com/ziglang/zig/issues/5675

const math = @import("std").math;
const Game = @import("othello");
const eval = @import("./eval.zig");
const Self = @This();

depth: u8,
comptime eval: fn (Game) i64 = eval.good,

fn ab(self: *Self, game: Game, alpha: i64, beta: i64, depth: u8) struct { value: i64, move: u6 } {
    if (depth == 0) return .{ .value = self.eval(game), .move = 0 };
    var moves = game.moves();
    if (moves == 0) return .{ .value = ~self.ab(game.pass(), ~beta, ~alpha, depth - 1).value, .move = 0 };

    var max: i64 = math.minInt(i64); //should change
    var pv: u6 = 0;
    if (depth > 5) {
        pv = self.ab(game, alpha, beta, 3).move;
        if (moves & (@as(u64, 1) << pv) != 0) {
            moves ^= (@as(u64, 1) << pv);
            max = ~self.ab(game.move(pv).?, ~beta, ~alpha, depth - 1).value;
            if (max >= beta)
                moves = 0;
        }
    }
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~self.ab(game.move(i).?, ~beta, ~math.max(alpha, max), depth - 1).value;
        if (j > max) {
            max = j;
            pv = i;
        }
        if (j >= beta) break;
    }
    return .{ .value = max, .move = pv };
}

pub fn move(self: *Self, game: Game) u6 {
    if (game.moves() == 0 or self.depth == 0) return 0;
    const alpha: i64 = math.minInt(i64);
    const beta: i64 = math.maxInt(i64);
    return self.ab(game, alpha, beta, self.depth).move;
}
