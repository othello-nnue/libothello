const std = @import("std");
const Game = @import("othello");
const engine = @import("engine");
const starts = @import("./starts.zig");

// add randomness by
// using agents by random
// and maybe linearly regress?

fn bench(startpos: Game, engine1: anytype, engine2: anytype, moves_by_engine2: u64) struct { final: Game, white: u64, black: u64 } {
    var s = moves_by_engine2;
    var side: u1 = 0;
    var white: u64 = 0;
    var black: u64 = 0;
    var game = startpos;
    while (!game.end()) : (s >>= 1) {
        if (game.moves() == 0) {
            game = game.pass();
        } else side = ~side;
        white = (white << 1) | (side);
        black = (black << 1) | (~side);
        var move: u6 = undefined;
        switch (@truncate(u1, s)) {
            0 => move = engine1.move(game),
            1 => move = engine2.move(game),
        }
        game = game.move(move).?;
        //std.debug.print("{}, move:{}, white:{}, black:{}\n", .{game,move,white,black});
    }
}

//do something...
//gen data so that we dump json and perform linear regression
pub fn main2() anyerror!void {
    //would change to more "reproducible" and "small" RNG
    //some day...
    var rand = std.rand.Xoroshiro128.init(0);
    const start = Game{};
    const a = engine.ab{ .depth = 4, .eval = engine.evals.mobility };
    const b = engine.ab{ .depth = 6, .eval = engine.evals.mobility };

    //const stdout = std.io.getStdOut().writer();
    //std.debug.print("score, white, black\n");
    std.debug.print("score, white1, white2, black1, black2\n", .{});
    var i: u64 = 0;
    while (i < 0x200) : (i += 1) {
        var moves = rand.random.int(u64);
        var x = bench(start, a, b, moves);
        //const white_ratio:f64 = @intToFloat(f64, @popCount(u64, x.white & moves))/ @intToFloat(f64, @popCount(u64, x.white));
        //const black_ratio:f64 = @intToFloat(f64, @popCount(u64, x.black & moves))/ @intToFloat(f64, @popCount(u64, x.black));
        //try std.json.stringify(x, .{}, stdout);

        //std.debug.print("\n{}\n", .{moves});
        //std.debug.print("{}, {}, {}\n", .{x.final.score(), white_ratio, black_ratio});
        std.debug.print("{}, {}, {}, {}, {}\n", .{ x.final.score(), @popCount(u64, x.white & moves), @popCount(u64, x.white & ~moves), @popCount(u64, x.black & moves), @popCount(u64, x.black & ~moves) });
    }
}
