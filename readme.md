# Intro

This is [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello), currently optimized for Intel Skylake microarchitecture.

# Move generation

Move generation is implemented with the Kogge-Stone Algorithm, intended to compile to SIMD operations. Though theoretically it can be further optimized using AVX512 bit rotation instructions, it is not done for following reasons. 

1. AVX512 instructions cause significant frequency throttling, resulting in a performance degradation in mixed workload. 
2. [Zig](ziglang.org)'s SIMD is not documented well currently. 
3. I didn't implement micro-benchmarking yet, so I can't even grasp about performance improvement/regression. 

Therefore, for now it relies mainly on LLVM's auto vectorization. 

# Move resolution

Move resolution is implemented using PDEP/PEXT bitboard with 18.5KiB of LUT which would fit in the L1D cache. 