fn deltaswap(x: u64, shift: u6, mask: u64) u64 {
    const y = (x ^ (x >> shift)) & mask;
    return x ^ y ^ @shlExact(y, shift);
}

fn deltaswap3(x: u64, shift: u6, mask: u64) u64 {
    return (x & ~(mask | mask << shift)) | ((x >> shift) & mask) | ((x & mask) << shift);
}

fn deltaswap(x: u64, shift: u6, mask: u64) u64 {
    const a = deltaswap3(x, shift, mask);
    const b = deltaswap3(x, shift, mask);
    if (a != b) unreachable;
    return a;
}
export fn flipVertical(x: u64) u64 {
    //var y = deltaswap(x, 8, 0x00FF00FF00FF00FF);
    //y = deltaswap(y, 16, 0x0000FFFF0000FFFF);
    //return deltaswap(y, 32, 0x00000000FFFFFFFF);
    return @byteSwap(u64, x);
}

export fn mirrorHorizontal(x: u64) u64 {
    //var y = deltaswap(x, 1, 0x5555555555555555);
    //y = deltaswap(y, 2, 0x3333333333333333);
    //return deltaswap(y, 4, 0x0f0f0f0f0f0f0f0f);
    return @byteSwap(u64, @bitReverse(u64, x));
}

export fn flipDiagA8H1(x: u64) u64 {
    var y = deltaswap(x, 9, 0xaa00aa00aa00aa00 >> 9);
    y = deltaswap(y, 18, 0xcccc0000cccc0000 >> 18);
    return deltaswap(y, 36, 0x0f0f_0f0f);
}

export fn flipDiagA1H8(x: u64) u64 {
    var y = deltaswap(x, 9, 0xaa00aa00aa00aa00 >> 9);
    y = deltaswap(y, 18, 0xcccc0000cccc0000 >> 18);
    return deltaswap(y, 36, 0x0f0f_0f0f);
}

fn testbit(t: comptime fn (u6) u6, u: comptime fn (u64) u64) bool {
    comptime var i = 0;
    inline while (i < 64) : (i += 1)
        if (@as(u64, 1) << t(i) != u(@as(u64, 1) << i))
            return false;
    return true;
}
