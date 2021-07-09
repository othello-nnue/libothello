using Libdl
othello = Libdl.dlopen("./zig-out/lib/libothello")
sym_moves = Libdl.dlsym(othello, :moves)

function moves(a::UInt64, b::UInt64)
    return ccall(sym_moves, UInt64, (UInt64, UInt64), a, b)
end

function move(a::UInt64, b::UInt64, c::UInt8)
    return ccall(sym_moves, UInt64, (UInt64, UInt64, UInt8), a, b, c)
end

using Test
@test 0x0000_1020_0408_0000 == moves(0x0000_0008_1000_0000, 0x0000_0010_0800_0000)