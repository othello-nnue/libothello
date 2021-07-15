const Self = @This();
const assert = @import("std").debug.assert;
const mul = @import("utils").mul;

board: [2]u64 = .{ 0x0000_0008_1000_0000, 0x0000_0010_0800_0000 },

fn fill(board: [2]u64, comptime dir: u6) u64 {
    var x = board[0];
    var y = board[1] & comptime switch (@mod(dir, 8)) {
        0 => mul(0xFF, 0xFF),
        1, 7 => mul(0xFF, 0x7E),
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        x |= (y & x << d) | (y >> (d - dir) & x >> d);
        y &= y << d;
    }
    return x;
}

/// Returns the set of legal moves. 
pub fn moves(self: Self) u64 {
    assert(self.board[0] & self.board[1] == 0);
    var ret: u64 = 0;
    inline for (.{ 1, 7, 8, 9 }) |i| {
        var temp = fill(self.board, i) & self.board[1];
        ret |= temp << i | temp >> i;
    }
    return ret & ~self.board[0] & ~self.board[1];
}

const pdep = @import("utils").pdep;
const pext = @import("utils").pext;

const MASK = @import("lut/mask.zig").MASK;
const INDEX = @import("lut/index.zig").INDEX;
const RESULT = @import("lut/test.zig").known;

/// Returns the set of stones that would be flipped.  
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
/// Returns the state after move. 
pub fn move(self: Self, place: u6) ?Self {
    assert(self.board[0] & self.board[1] == 0);
    if (@as(u64, 1) << place & (self.board[0] | self.board[1]) != 0) return null;
    const t = self.flip(place);
    if (t == 0) return null;
    const temp = [2]u64{ self.board[1] ^ t, self.board[0] ^ t ^ (@as(u64, 1) << place) };
    return Self{ .board = temp };
}

// https://github.com/ziglang/zig/issues/3696
/// Returns the state after pass. 
pub fn pass(self: Self) Self {
    assert(self.board[0] & self.board[1] == 0);
    const temp = Self{ .board = .{ self.board[1], self.board[0] } };
    return temp;
}

/// Returns if the game ended. 
/// Whether neither player can move.
pub fn end(self: Self) bool {
    assert(self.board[0] & self.board[1] == 0);
    return self.moves() == 0 and self.pass().moves() == 0;
}

// actually i7 is enough
/// Returns final score. 
pub fn score(self: Self) i8 {
    assert(self.board[0] & self.board[1] == 0);
    return @as(i8, @popCount(u64, self.board[0])) - 32;
}

/// Returns move number. 
pub fn movenum(self: Self) u6 {
    assert(self.board[0] & self.board[1] == 0);
    return @popCount(u64, self.board[0] | self.board[1]);
}

const filled = @import("utils").fill;

fn unflippable(a: u64, b: u64) u64 {
    var ret: u64 = 0;
    var fil = ~(a | b);
    while (true) {
        var c = a;
        inline for (.{ 1, 7, 8, 9 }) |i|
            c &= ~switch (i) {
                1 => mul(0xFF, 0x7E),
                8 => mul(0x7E, 0xFF),
                7, 9 => mul(0x7E, 0x7E),
                else => unreachable,
            } | ~filled(fil, i) | ret >> i | ret << i;
        if (ret == c)
            return ret;
        ret = c;
    }
}

/// Returns (subset of) unflippable stones.
pub fn stable(self: Self) u64 {
    return unflippable(self.board[0], self.board[1]) | unflippable(self.board[1], self.board[0]);
}
