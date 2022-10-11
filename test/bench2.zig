const tests = @import("perft");
const Game = @import("othello");

pub fn main() anyerror!void {
    Game.init();
    // tests.print_avx512_usage();
    _ = tests.perft(.{}, 12);
}
