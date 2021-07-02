const othello = @import("./main.zig");
const assert = @import("std").debug.assert;

pub const Game = struct {
    const Self = @This();

    board: [2]u64 = othello.init(),

    pub fn moves(self: Self) u64 {
        return othello.moves(self.board);
    }

    pub fn move(self: Self, place: u6) ?Self {
        if (@as(u64, 1) << place & (self.board[0] | self.board[1]) != 0) return null;
        const t = othello.move(self.board, place);
        if (t == 0) return null;
        const ret = Self{ .board = .{ self.board[1] ^ t, self.board[0] ^ t ^ (@as(u64, 1) << place) } };
        assert(ret.board[0] & ret.board[1] == 0);
        return ret;
    }

    pub fn pass(self: Self) Self {
        const ret = Self{ .board = .{ self.board[1], self.board[0] } };
        assert(ret.board[0] & ret.board[1] == 0);
        return ret;
    }

    pub fn end(self: Self) bool {
        return self.moves() == 0 and self.pass().moves() == 0;
    }

    // actually i7 is enough
    pub fn score(self: Self) i8 {
        return @as(i8, @popCount(u64, self.board[0])) - 32;
    }
};
