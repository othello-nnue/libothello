from ctypes import *
othello = CDLL("./zig-out/lib/libothello.so")

moves = othello.moves
moves.argtypes=[c_uint64, c_uint64]
moves.restype=c_uint64

flip = othello.flip
flip.argtypes = [c_uint64, c_uint64, c_uint8]
flip.restype = c_uint64