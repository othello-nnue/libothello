//https://github.com/ziglang/zig/issues/5675

const math = @import("std").math;
const Game = @import("othello");
const eval = @import("./eval.zig");
const Self = @This();

const Value = i8;

const Entry = struct { hash: u64, move: u6, depth: u8, ub: Value, lb: Value };
const Result = struct { value: Value, move: u6 };

depth: u8,
pvmove: [0x10000]Entry = [1]Entry{Entry{ .hash = 0, .move = 0, .depth = 0, .ub = 0, .lb = 0 }} ** 0x10000,
comptime eval: fn (Game) Value = eval.goods,

fn hash2(game: Game) u64 {
    const x = @as(u128, game.board[0]) * @as(u128, game.board[1]);
    const t = @truncate(u64, x);
    const u = @truncate(u64, x >> 64);
    return @truncate(u16, t +% u);
}

fn hash(game: Game) u64 {
    const x = game.board[0] *% 0x387d_458f_1b15_a8b3;
    const y = game.board[1] *% 0xf7eb_a921_0948_4175;
    const xx = @byteSwap(u64, x);
    const yy = @byteSwap(u64, y);
    const xxx = xx *% 0x4701_9b3f_ed2c_7fcd;
    const yyy = yy *% 0x2ca3_8a77_f033_11d5;
    return xxx +% yyy;
}

fn ab(self: *Self, game: Game, alpha: Value, beta: Value, depth: u8) Result {
    if (depth == 0) return .{ .value = self.eval(game), .move = undefined };
    const hashed = hash(game);
    const entry = self.pvmove[@truncate(u16, hashed)];
    var a = alpha;
    var b = beta;

    var moves = game.moves();
    if (moves == 0) return .{ .value = ~self.ab(game.pass(), ~b, ~a, depth - 1).value, .move = 0 };

    var pv = entry.move;
    const positive = (moves & (@as(u64, 1) << entry.move) != 0) and (hashed == entry.hash);

    if (positive and entry.depth == depth) {
        if (entry.lb >= beta) return .{ .value = entry.lb, .move = entry.move };
        if (entry.ub <= alpha) return .{ .value = entry.ub, .move = entry.move };
        a = math.max(a, entry.lb);
        b = math.min(b, entry.ub);
    }

    var max: Value = math.minInt(Value);
    if (depth > 5 or positive) {
        if (!positive) pv = self.ab(game, alpha, beta, 3).move;
        moves ^= (@as(u64, 1) << pv);
        max = ~self.ab(game.move(pv).?, ~beta, ~alpha, depth - 1).value;
    }

    while (moves != 0 and max < beta) {
        const i = @intCast(u6, @ctz(u64, moves));
        moves &= moves - 1;
        const j = ~self.ab(game.move(i).?, ~b, ~math.max(a, max), depth - 1).value;
        if (j > max) {
            max = j;
            pv = i;
        }
    }
    if (depth >= entry.depth) {
        var lb: Value = math.minInt(Value);
        var ub: Value = math.maxInt(Value);
        if (positive) {
            lb = entry.lb;
            ub = entry.ub;
        }
        if (max >= beta) {
            lb = max;
        } else if (max <= alpha) {
            ub = max;
        } else {
            ub = max;
            lb = max;
        }
        self.pvmove[@truncate(u16, hashed)] = .{
            .depth = depth,
            .lb = lb,
            .ub = ub,
            .hash = hashed,
            .move = pv,
        };
    }
    return .{ .value = max, .move = pv };
}

fn mtdf(self: *Self, game: Game, depth: u8, guess: Value) Result {
    var g = guess;
    var lb: Value = math.minInt(Value);
    var ub: Value = math.maxInt(Value);
    var pv: u6 = undefined;
    while (lb < ub) {
        var beta = g;
        if (g == lb) beta += 1;
        var temp = self.ab(game, beta - 1, beta, depth);
        g = temp.value;
        pv = temp.move;
        if (g < beta) {
            ub = g;
        } else {
            lb = g;
        }
    }
    return .{ .value = g, .move = pv };
}

pub fn move(self: *Self, game: Game) u6 {
    var g = Result{ .value = 0, .move = undefined };
    var d = (self.depth + 1) % 2 + 1;
    while (d <= self.depth) : (d += 2) {
        g = self.mtdf(game, d, g.value);
    }
    return g.move;
}
