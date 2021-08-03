# Introduction
This is [Zig](ziglang.org) port of [Othello move generator](https://gitlab.com/rust-othello/8x8-othello).

# Directory structure

# Move generation
We use [Kogge-Stone Algorithm](https://www.chessprogramming.org/Kogge-Stone_Algorithm), intended to compile to SIMD instructions, for move generation. 

# Move resolution
## AMD64
On x86-64-v3 processors it uses PDEP/PEXT instructions and 16.5KiB of LUT, which would fit in the L1D cache. I have an idea to reduce LUT size to 14.5KiB, I might switch to that implementation after benchmarking.  

Name | Type | Size
----:|----:|----:
`index`|`[64][4]u16`|0.5KiB
`mask`|`[64][4][2]u64`|4KiB
`result`|`[0x3000]u8`|12KiB

## ARM
On ARM processors it uses [rbit instruction](https://developer.arm.com/documentation/ddi0596/2021-06/Base-Instructions/RBIT--Reverse-Bits-) and 2KiB of LUT
implementing [Hyperbola Quintessence](https://www.chessprogramming.org/Hyperbola_Quintessence).

Name | Type | Size
----:|----:|----:
`mask`|`[64][4]u64`|2KiB

# Evaluation

## AlphaZero
We use AlphaZero to generate high quality games, and train NNUE on those games. 

## PoZero
There is an [improved](https://arxiv.org/abs/2007.12509) version of AlphaZero, allowing to work better on low-nodes regime. 

## Improved PoZero
The value of a node is approximately $\mathbb{q}\cdot\boldsymbol{\hat{\pi}}$ where $q_0$ is the initial value estimate. We instead use roughly $\mathbb{q}\cdot\boldsymbol{\bar{\pi}}$ which is the value when both agent plays with the search poliy. This allows value to propagate in a more minimax-like way.

"When a promising new (high-value) leaf is discovered, many additional simulations might be needed before this information is reflected in $\hat{\pi}$; since $\bar{\pi}$ is directly computed from Q-values, this information is updated instantly."

## DAG
With above modifications, the search does not rely on the number of visits of child nodes, therefore it can be used on any DAG. 
