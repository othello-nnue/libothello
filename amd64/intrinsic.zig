// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;
extern fn @"llvm.x86.bmi.pext.64"(u64, u64) u64;
extern fn @"llvm.assume"(bool) void;

//todo : ARM SVE2
const vscale = undefined;
extern fn @"llvm.aarch64.sve.bdep.x.nx2i64"(@Vector(2 * vscale, u64), @Vector(2 * vscale, u64)) @Vector(2 * vscale, u64);
extern fn @"llvm.aarch64.sve.bext.x.nx2i64"(@Vector(2 * vscale, u64), @Vector(2 * vscale, u64)) @Vector(2 * vscale, u64);
//ld1b gather

//todo : RISC-V
extern fn @"llvm.riscv.bdepw.i64"(u64, u64) u64;
extern fn @"llvm.riscv.bextw.i64"(u64, u64) u64;

// export LLVM pdep/pext intrinsic
pub inline fn pext(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pext.64"(a, b);
}
pub inline fn pdep(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pdep.64"(a, b);
}
pub inline fn assume(a: bool) void {
    @"llvm.assume"(a);
}
