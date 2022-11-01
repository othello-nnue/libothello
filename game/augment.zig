const mul = @import("utils").mul;
fn deltaswap(bits: u64, shift: u6, mask: u64) u64 {
    const delta = (bits ^ (bits >> shift)) & mask;
    return bits ^ delta ^ @shlExact(delta, shift);
}

fn vert(x: u64) u64 {
    return @byteSwap(x);
}

fn hori(x: u64) u64 {
    return @bitReverse(@byteSwap(x));
}

fn rot(x: u64) u64 {
    return @bitReverse(x);
}

fn diag(x: u64) u64 {
    var y = deltaswap(x, 7, mul(0x55, 0xaa));
    y = deltaswap(y, 14, mul(0x33, 0xcc));
    return deltaswap(y, 28, mul(0x0f, 0xf0));
}
//antidiagonal
fn gaid(x: u64) u64 {
    var y = deltaswap(x, 9, mul(0x55, 0x55));
    y = deltaswap(y, 18, mul(0x33, 0x33));
    return deltaswap(y, 36, mul(0x0f, 0x0f));
}

fn rot1(x: u64) u64 {
    return vert(diag(x));
}

fn rot3(x: u64) u64 {
    return vert(gaid(x));
}

// optimized for AMD64
// should use avx512 later?
fn tot(x: u64) [8]u64 {
    //does not work(yet)
    //return half(x) ++ half(vert(x));
    return .{ x, hori(x), vert(x), hori(vert(x)), diag(x), gaid(x), diag(vert(x)), gaid(vert(x)) };
}

// optimized for ARM64
fn tot2(x: u64) [8]u64 {
    return .{ x, vert(x), rot(x), hori(x), diag(x), diag(vert(x)), diag(rot(x)), diag(hori(x)) };
}

fn testbit(comptime t: fn (u6) u6, comptime u: fn (u64) u64) bool {
    comptime var i = 0;
    inline while (i < 64) : (i += 1)
        if (@as(u64, 1) << t(i) != u(@as(u64, 1) << i))
            return false;
    return true;
}

fn ver(a: u6) u6 {
    return a ^ 56;
}
fn hor(a: u6) u6 {
    return a ^ 7;
}
fn dia(a: u6) u6 {
    return (a << 3) | (a >> 3);
}
fn aid(a: u6) u6 {
    return (~a << 3) | (~a >> 3);
}

const expect = @import("std").testing.expect;
test {
    try expect(testbit(ver, vert));
    try expect(testbit(hor, hori));
    try expect(testbit(dia, diag));
    try expect(testbit(aid, gaid));
}
