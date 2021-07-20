const Game = @import("othello");
const testing = @import("./test.zig");

pub fn main() void {
    var i: u8 = 0;
    while (i < 14) : (i += 1) {
        @import("std").debug.print("{}\n", .{testing.perft(.{}, i)});
    }
}
