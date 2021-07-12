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

fn filled(a: u64, comptime dir: u6) u64 {
    var b = ~a;
    comptime var x = switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1 => 0xFEFE_FEFE_FEFE_FEFE,
        7 => 0x7F7F_7F7F_7F7F_7F7F,
        else => unreachable,
    };
    comptime var y = switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1 => 0x7F7F_7F7F_7F7F_7F7F,
        7 => 0xFEFE_FEFE_FEFE_FEFE,
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        b |= (b << d & x) | (b >> d & y);
        x &= x << d;
        y &= y >> d;
    }
    return comptime switch (dir) {
        8 => 0xFF00_0000_0000_00FF,
        1 => 0x8181_8181_8181_8181,
        7, 9 => 0xFF81_8181_8181_81FF,
        else => unreachable,
    } | ~b;
}

//not all
export fn stable(a: u64, b: u64) u64 {
    var ret: u64 = 0;
    var fil = a | b;
    while (true) {
        var c = a;
        inline for (.{ 1, 7, 8, 9 }) |i|
            c &= ret >> i | ret << i | filled(fil, i);
        if (ret == c)
            return ret;
        ret = c;
    }
}
