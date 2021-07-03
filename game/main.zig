const Self = @This();
const assert = @import("std").debug.assert;

board: [2]u64 = .{ 0x0000_0008_1000_0000, 0x0000_0010_0800_0000 },

fn gen(board: [2]u64, comptime dir: u6) u64 {
    var x = board[0];
    var y = board[0];
    var z = board[1] & comptime switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1, 7 => 0x7E7E_7E7E_7E7E_7E7E,
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        x |= z & (x << d);
        y |= (z << dir & y) >> d;
        z &= z << d;
    }
    return (x ^ board[0]) << dir | (y ^ board[0]) >> dir;
}

pub fn moves(self: Self) u64 {
    assert(self.board[0] & self.board[1] == 0);
    var ret: u64 = 0;
    inline for (.{ 1, 7, 8, 9 }) |i|
        ret |= gen(self.board, i);
    return ret & ~self.board[0] & ~self.board[1];
}

const pdep = @import("./intrinsic.zig").pdep;
const pext = @import("./intrinsic.zig").pext;

const MASK = @import("lut/mask.zig").MASK;
const INDEX = @import("lut/index.zig").INDEX;
const RESULT = @import("lut/test.zig").known;

pub fn flip(self: Self, place: u6) u64 {
    assert(self.board[0] & self.board[1] == 0);
    var ret: u64 = 0;
    comptime var i = 0;
    inline while (i < 4) : (i += 1)
        ret |= pdep(RESULT[
            @as(u64, INDEX[place][i]) * 32 + pext(self.board[0], MASK[place][i][0]) * 64 + pext(self.board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
    return ret;
}

// https://github.com/ziglang/zig/issues/3696
pub fn move(self: Self, place: u6) ?Self {
    assert(self.board[0] & self.board[1] == 0);
    if (@as(u64, 1) << place & (self.board[0] | self.board[1]) != 0) return null;
    const t = self.flip(place);
    if (t == 0) return null;
    const temp = [2]u64{ self.board[1] ^ t, self.board[0] ^ t ^ (@as(u64, 1) << place) };
    return Self{ .board = temp };
}

// https://github.com/ziglang/zig/issues/3696
pub fn pass(self: Self) Self {
    assert(self.board[0] & self.board[1] == 0);
    const temp = Self{ .board = .{ self.board[1], self.board[0] } };
    return temp;
}

pub fn end(self: Self) bool {
    assert(self.board[0] & self.board[1] == 0);
    return self.moves() == 0 and self.pass().moves() == 0;
}

// actually i7 is enough
pub fn score(self: Self) i8 {
    assert(self.board[0] & self.board[1] == 0);
    return @as(i8, @popCount(u64, self.board[0])) - 32;
}

pub fn movenum(self: Self) u6 {
    assert(self.board[0] & self.board[1] == 0);
    return @popCount(u64, self.board[0] | self.board[1]);
}
