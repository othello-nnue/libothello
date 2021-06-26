const othello = @import("othello");

pub fn simple_engine(board: [2]u64) struct { move: u6, board: [2]u64 } {
    var x = othello.moves(board);
    var ret: u6 = 0;
    var min: u7 = 64;
    var ret2: [2]u64 = undefined;
    while (x != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        const t = othello.move(board, i);

        moves ^= @as(u64, 1) << i;
        const j = .{ board[1] ^ t, board[0] ^ t ^ (@as(u64, 1) << i) };
        const k = @popCount(u64, othello.moves(j));
        if (k < min) {
            min = k;
            ret = i;
            ret2 = j;
        }
    }
    return .{ .move = ret, .board = ret2 };
}
