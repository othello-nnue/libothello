const othello = @import("./main.zig");

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
        return Self{ .board = .{ self.board[1] ^ t, self.board[0] ^ t ^ (@as(u64, 1) << place) } };
    }
};
