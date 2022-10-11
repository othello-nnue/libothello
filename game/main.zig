const Self = @This();
const assert = @import("std").debug.assert;
const mul = @import("utils").mul;

board: [2]u64 = .{ 0x0000_0008_1000_0000, 0x0000_0010_0800_0000 },

pub fn init() void {
    @import("arch").prefetch();
}

/// Returns the set of legal moves.
pub fn moves_default(self: Self) u64 {
    const s = @Vector(4, u6){ 1, 7, 8, 9 };
    const t = s *% @splat(4, @as(u6, 2));
    const m = @Vector(4, u64){ mul(0xFF, 0x7E), mul(0xFF, 0x7E), mul(0xFF, 0xFF), mul(0xFF, 0x7E) };

    var x = @splat(4, self.board[0]);
    var y = @splat(4, self.board[1]) & m;

    x = y & (x << s | x >> s);
    x |= y & (x << s | x >> s);
    y &= y << s;
    x |= (y & x << t) | (y >> s & x >> t);
    x |= (y & x << t) | (y >> s & x >> t);

    x = x << s | x >> s;
    return @reduce(.Or, x) & ~self.board[0] & ~self.board[1];
}

fn rot(a: @Vector(8, u64), b: @Vector(8, u6)) @Vector(8, u64) {
    return (a << b) | (a >> (-%b));
}

/// Returns the set of legal moves.
/// AVX-512 optimized
pub fn moves_avx512(self: Self) u64 {
    const s = @Vector(8, u6){ 1, 7, 8, 9, 63, 57, 56, 55 };
    const t = s *% @splat(8, @as(u6, 2));
    const m = @Vector(8, u64){ mul(0xFF, 0x7E), mul(0x7E, 0x7E), mul(0x7E, 0xFF), mul(0x7E, 0x7E), mul(0xFF, 0x7E), mul(0x7E, 0x7E), mul(0x7E, 0xFF), mul(0x7E, 0x7E) };

    var x = @splat(8, self.board[0]);
    var y = @splat(8, self.board[1]) & m;
    const z = rot(y, s);

    x |= y & rot(x, s);
    y &= z;
    x |= y & rot(x, t);
    x |= y & rot(x, t);
    x = z & rot(x, t);

    return @reduce(.Or, x) & ~self.board[0] & ~self.board[1];
}

const has = @import("std").Target.x86.featureSetHas;
const cpu = @import("builtin").target.cpu;
pub const has_avx512 = (cpu.arch == .x86_64) and has(cpu.features, .avx512f);

/// Returns the set of legal moves.
pub fn moves(self: Self) u64 {
    assert(self.board[0] & self.board[1] == 0);
    return if (has_avx512) moves_avx512(self) else moves_default(self);
}

/// Returns the set of stones that would be flipped.
/// with some possible errors(to be documented)
pub fn flip(self: Self, place: u6) u64 {
    assert(self.board[0] & self.board[1] == 0);
    return @import("arch").flip(self.board, place);
}

// https://github.com/ziglang/zig/issues/3696
/// Returns the state after move.
pub fn move(self: Self, place: u6) ?Self {
    assert(self.board[0] & self.board[1] == 0);
    if (@as(u64, 1) << place & (self.board[0] | self.board[1]) != 0) return null;
    const t = self.flip(place);
    if (t == 0) return null;
    const temp = [2]u64{ self.board[1] & ~t, self.board[0] | t | (@as(u64, 1) << place) };
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
    return @as(i8, @popCount(self.board[0])) - 32;
}

/// Returns move number.
pub fn movenum(self: Self) u6 {
    assert(self.board[0] & self.board[1] == 0);
    return @popCount(self.board[0] | self.board[1]);
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

const expect = @import("std").testing.expect;
test "init test" {
    const i = Self{};
    const j = i.moves();
    try expect(j == 0x0000_1020_0408_0000);
}

test "size test" {
    try expect(@sizeOf(Self) == 16);
}

// https://github.com/ziglang/zig/issues/3696
test "assign test" {
    var g = Self{};
    g = g.pass();
    try expect(g.board[0] != g.board[1]);
}
