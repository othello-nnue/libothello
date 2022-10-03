# Introduction
This is [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello).

# Directory structure

    .
    ├── amd64       # AMD64-specific codes
    ├── arm64       # ARM64-specific codes
    ├── utils       # Utility functions
    ├── game        # Othello implementation
    ├── test        # Behavior tests and benchmarks
    ├── build.zig   # build file
    └── readme.md

# Move generation
We implement [Kogge-Stone Algorithm](https://www.chessprogramming.org/Kogge-Stone_Algorithm) for move generation. On x86-64-v4 CPUs, we use rotation instead of shifts to scan 8 directions simultaneously. We use bidirectional Kogge-Stone for other CPUs.

# Move resolution
## AMD64
On x86-64-v3 processors we implement PDEP/PEXT bitboard using 20.5KiB of LUT, which would fit in the L1D cache. 

Name | Type | Size
----:|----:|----:
`index`|`[64][4]u16`|0.5KiB
`mask`|`[64][4][2]u64`|4KiB
`result`|`[0x4000]u6`|16KiB

(it can be reduced by 2KiB)

## ARM
On ARM processors we implement [Hyperbola Quintessence](https://www.chessprogramming.org/Hyperbola_Quintessence) using [rbit instruction](https://developer.arm.com/documentation/ddi0596/2021-06/Base-Instructions/RBIT--Reverse-Bits-) and 2KiB of LUT.

Name | Type | Size
----:|----:|----:
`mask`|`[64][4]u64`|2KiB

# Performance

Perft suggests this repo is about 2X faster than edax-reversi-AVX. But note that:
1. [Some libraries](https://github.com/Gigantua/Gigantua) can generate moves faster than stockfish because stockfish generates incremental eval info simultaneously.
2. The definition of perft is different. Specifically, we ignore the game termination condition.

# History

This repo started as a [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello), which uses the same algorithm. We chose Zig for the following reasons. 
1. Zig has excellent `comptime` support, which is crucial for building LUTs.
2. Zig supports portable SIMD. 