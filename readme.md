# Introduction
This is [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello).

# Directory structure

    .
    ├── engine      # Engine code
    ├── game        # Othello implementation
    │   ├── amd64   # AMD64-specific codes
    │   └── arm64   # ARM64-specific codes
    ├── game        # Othello implementation
    ├── perf        # Benchmark tests
    ├── training    # NNUE training 
    ├── tui         # Othello on terminal
    ├── build.zig   # build file
    └── readme.md

# Move generation
We implement [Kogge-Stone Algorithm](https://www.chessprogramming.org/Kogge-Stone_Algorithm) for move generation. It should compile to vector instructions. 

# Move resolution
## AMD64
On x86-64-v3 processors we implement PDEP/PEXT bitboard using 16.5KiB of LUT, which would fit in the L1D cache. We are working to reduce LUT further without harming performance. 

Name | Type | Size
----:|----:|----:
`index`|`[64][4]u16`|0.5KiB
`mask`|`[64][4][2]u64`|4KiB
`result`|`[0x3000]u8`|12KiB

## ARM
On ARM processors we implement [Hyperbola Quintessence](https://www.chessprogramming.org/Hyperbola_Quintessence) using [rbit instruction](https://developer.arm.com/documentation/ddi0596/2021-06/Base-Instructions/RBIT--Reverse-Bits-) and 2KiB of LUT.

Name | Type | Size
----:|----:|----:
`mask`|`[64][4]u64`|2KiB

# Evaluation

## AlphaZero
We train an [improved](https://arxiv.org/abs/2007.12509) version of AlphaZero, which generates game for NNUE training data. 
