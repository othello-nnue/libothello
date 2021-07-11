// https://github.com/ziglang/zig/issues/2291

extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;
extern fn @"llvm.x86.bmi.pext.64"(u64, u64) u64;

pub inline fn pext(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pext.64"(a, b);
}

pub inline fn pdep(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pdep.64"(a, b);
}

pub inline fn mul(x: u8, y: u8) u64 {
    return pdep(x, 0x0101_0101_0101_0101) * y;
}
