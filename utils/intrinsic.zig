// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;
extern fn @"llvm.x86.bmi.pext.64"(u64, u64) u64;

// export LLVM pdep/pext intrinsic
pub inline fn pext(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pext.64"(a, b);
}
pub inline fn pdep(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pdep.64"(a, b);
}
