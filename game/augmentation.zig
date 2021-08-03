const mul = @import("./utils.zig").mul;
fn deltaswap(x: u64, shift: u6, mask: u64) u64 {
    const y = (x ^ (x >> shift)) & mask;
    return x ^ y ^ @shlExact(y, shift);
}

fn vert(x: u64) u64 {
    return @byteSwap(u64, x);
}

fn hori(x: u64) u64 {
    return @byteSwap(u64, @bitReverse(u64, x));
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
