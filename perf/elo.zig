const std = @import("std");
const Game = @import("othello");
const bench = @import("bench");

// add randomness by
// using agents by random
// and maybe linearly regress?
const Data = struct {
    movewhite: u8,
    moveblack: u8,
    score: i8,
    sequence: u1,
    seed: u64,
};
fn bench(engine1: anytype, engine2: anytype, seed: u64) struct { Game, u64 } {
    var s = seed;
    var side: u1 = 0;
    var white: u64 = 0;
    var game = Game{};
    while (!game.end()) : (s >>= 1) {
        if (game.moves() == 0) {
            game = game.pass();
        } else side = ~side;
        white = (white << 1) + side;
        var move: u6 = undefined;
        switch (@truncate(u1, s)) {
            0 => move = engine1.play(game),
            1 => move = engine2.play(game),
        }
        game = game.move(move);
    }
    if (side == 1) game = game.pass();
    return .{ game, white };
    //should return black also?
}
//do something...
//gen data so that we dump json and perform linear regression
fn gendata() void {}
