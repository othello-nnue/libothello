//https://github.com/ziglang/zig/issues/5675

const math = @import("std").math;
const Game = @import("othello");
const eval = @import("./eval.zig");
const Self = @This();

const entry = struct { move: u6, depth: u8 };

depth: u8,
pvmove: [0x20000]entry = [1]entry{entry{ .move = 0, .depth = 0 }} ** 0x20000,
comptime eval: fn (Game) i64 = eval.good,

fn hash2(game: Game) u64 {
    const x = @as(u128, game.board[0]) * @as(u128, game.board[1]);
    const t = @truncate(u64, x);
    const u = @truncate(u64, x >> 64);
    return @truncate(u17, t +% u);
}

fn hash(game: Game) u64 {
    const x = game.board[0] *% 0x387d_458f_1b15_a8b3;
    const y = game.board[1] *% 0xf7eb_a921_0948_4175;
    const xx = (x << 32) | (x >> 32);
    const yy = (y << 32) | (y >> 32);
    const xxx = xx *% 0x4701_9b3f_ed2c_7fcd;
    const yyy = yy *% 0x2ca3_8a77_f033_11d5;
    return @truncate(u17, xxx +% yyy);
}

fn ab(self: *Self, game: Game, alpha: i64, beta: i64, depth: u8) struct { value: i64, move: u6 } {
    if (depth == 0) return .{ .value = self.eval(game), .move = 0 };
    var moves = game.moves();
    if (moves == 0) return .{ .value = ~self.ab(game.pass(), ~beta, ~alpha, depth - 1).value, .move = 0 };

    var max: i64 = math.minInt(i64); //should change
    var pv: u6 = 0;
    if (depth > 5) {
        pv = self.pvmove[hash(game)].move;
        if (moves & (@as(u64, 1) << pv) != 0) {
            moves ^= (@as(u64, 1) << pv);
            max = ~self.ab(game.move(pv).?, ~beta, ~alpha, depth - 1).value;
            if (max >= beta)
                moves = 0;
        }
    }
    while (moves != 0) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~self.ab(game.move(i).?, ~beta, ~math.max(alpha, max), depth - 1).value;
        if (j > max) {
            max = j;
            pv = i;
        }
        if (j >= beta) break;
    }
    if (depth >= self.pvmove[hash(game)].depth and depth > 5) self.pvmove[hash(game)] = entry{ .depth = depth, .move = pv };
    return .{ .value = max, .move = pv };
}

pub fn move(self: *Self, game: Game) u6 {
    if (game.moves() == 0 or self.depth == 0) return 0;
    const alpha: i64 = math.minInt(i64);
    const beta: i64 = math.maxInt(i64);

    //var depth: u8 = 0;
    //while (depth < self.depth) : (depth += 1) {
    //    _ = self.ab(game, alpha, beta, self.depth);
    //}
    //_ = self.ab(game, alpha, beta, self.depth - 1);

    return self.ab(game, alpha, beta, self.depth).move;
}
