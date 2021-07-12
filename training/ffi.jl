module Othello
using Libdl
othello = Libdl.dlopen("./zig-out/lib/libothello")
sym_moves = Libdl.dlsym(othello, :moves)
sym_flip = Libdl.dlsym(othello, :flip)

export moves,flip

moves(a::UInt64, b::UInt64) =  ccall(sym_moves, UInt64, (UInt64, UInt64), a, b)
flip(a::UInt64, b::UInt64, c::UInt8) = ccall(sym_flip, UInt64, (UInt64, UInt64, UInt8), a, b, c)

using Test
@test 0x0000_1020_0408_0000 == moves(0x0000_0008_1000_0000, 0x0000_0010_0800_0000)
end