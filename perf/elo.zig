const std = @import("std");
const Game = @import("othello");
const engine = @import("engine");
const starts = @import("./starts.zig");

fn endpos(startpos: Game, engine1: anytype, engine2: anytype) i8 {
    var e1 = engine1;
    var e2 = engine2;
    var side: u1 = 0;
    var game = startpos;
    while (!game.end()) {
        if (game.moves() == 0) {
            game = game.pass();
        } else side = ~side;
        var move: u6 = undefined;
        switch (side) {
            0 => move = e1.move(game),
            1 => move = e2.move(game),
        }
        game = game.move(move).?;
    }
    const score = game.score();
    if (side != 0) {
        return score;
    } else return -score;
}

//positive when engine1 is better
fn sumscore(startpos: Game, engine1: anytype, engine2: anytype) i8 {
    return endpos(startpos, engine1, engine2) - endpos(startpos, engine2, engine1);
}

pub fn main2() void {
    const a = engine.ab3{ .depth = 12, .eval = engine.evals.good };
    //const b = engine.ab3{ .depth = 10, .eval = engine.evals.good };
    const b = engine.mtdf{ .depth = 12, .eval = engine.evals.goods };

    for (starts.START) |g| {
        std.debug.print("{}\n", .{sumscore(g, a, b)});
    }
}

pub fn main() void {
    //const a = engine.ab{ .depth = 11, .eval = engine.evals.good };
    //const a = engine.ab3{ .depth = 14, .eval = engine.evals.good };
    const a = engine.mtdf{ .depth = 16, .eval = engine.evals.goods };
    std.debug.print("{}\n", .{endpos(Game{}, a, a)});
}
