# Intro

This is [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello), currently optimized for Intel Skylake microarchitecture.

# Move generation

The move generation part implements the [Kogge-Stone Algorithm](https://www.chessprogramming.org/Kogge-Stone_Algorithm), intended to compile to SIMD instructions. 

# Move resolution

The move resolution part uses PDEP/PEXT instructions and 16.5KiB of LUT, which would fit in the L1D cache. 

Name | Type | Size
----:|----:|----:
`index`|`[64][4]u16`|0.5KiB
`mask`|`[64][4][2]u64`|4KiB
`result`|`[0x3000]u8`|12KiB
