const std = @import("std");
const Game = @import("othello");
const engine = @import("engine");
const starts = @import("./starts.zig");

var eng = engine.ab3{ .depth = 11, .eval = engine.evals.good };

fn endpos(startpos: Game, comptime ev: fn (Game) i64, depth: u8) void {
    var game = startpos;
    //var eng = engine.ab{ .depth = depth };
    while (!game.end()) {
        if (game.moves() == 0) {
            game = game.pass();
        }
        var i: u8 = 0;
        while (i <= depth) : (i += 1) {
            std.debug.print("{} ", .{engine.ab.ab(game, ev, std.math.minInt(i64), std.math.maxInt(i64), i)});
        }
        std.debug.print("\n", .{});
        var move: u6 = eng.move(game);
        game = game.move(move).?;
    }
}

pub fn main() void {
    endpos(Game{}, engine.evals.good, 10);
}
