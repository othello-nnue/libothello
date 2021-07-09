const std = @import("std");
const Game = @import("othello");
const engine = @import("engine");

fn shift(template: Game, s: u6) Game {
    return Game{ .board = .{ template.board[0] << s, template.board[1] << s } };
}
//need something...
//maybe pub `absearch` ?
fn filter(template: Game) bool {
    _ = template;
    return true;
}

fn new(a: u64, b: u64) Game {
    return Game{ .board = .{ a, b } };
}

pub const START = init: {
    const diag = new(0x0000_0008_1000_0000, 0x0000_0010_0800_0000);
    const reversi = new(0x0000_0018_0000_0000, 0x0000_0000_1800_0000);
    break :init [_]Game{
        diag,
        shift(diag, 1),
        shift(diag, 9),
        reversi,
        shift(reversi, 1),
        shift(reversi, 7),
        shift(reversi, 8),
    };
};
