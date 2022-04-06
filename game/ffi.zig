const game = @import("othello");
//https://github.com/ziglang/zig/issues/11312
export fn flip(a: u64, b: u64, c: u8) u64 {
    if (@truncate(u6, c) != c) unreachable;
    const x = game{ .board = .{ a, b } };
    return x.flip(@intCast(u6, c));
}

export fn moves(a: u64, b: u64) u64 {
    const x = game{ .board = .{ a, b } };
    return x.moves();
}

export fn stable(a: u64, b: u64) u64 {
    const x = game{ .board = .{ a, b } };
    return x.stable();
}

//easier to export each function
//isn't really performance critical
export fn vert(x: u64) u64 {
    return @byteSwap(u64, x);
}

export fn hori(x: u64) u64 {
    //return @byteSwap(u64, @bitReverse(u64, x));
    return @bitReverse(u64, @byteSwap(u64, x));
}

const mul = @import("utils").mul;
fn deltaswap(bits: u64, shift: u6, mask: u64) u64 {
    const delta = (bits ^ (bits >> shift)) & mask;
    return bits ^ delta ^ @shlExact(delta, shift);
}

export fn diag(x: u64) u64 {
    var y = deltaswap(x, 7, mul(0x55, 0xaa));
    y = deltaswap(y, 14, mul(0x33, 0xcc));
    return deltaswap(y, 28, mul(0x0f, 0xf0));
}
//antidiagonal
export fn gaid(x: u64) u64 {
    var y = deltaswap(x, 9, mul(0x55, 0x55));
    y = deltaswap(y, 18, mul(0x33, 0x33));
    return deltaswap(y, 36, mul(0x0f, 0x0f));
}
