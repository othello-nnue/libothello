pub fn init() [2]u64 {
    return [2]u64{ 0x0000_0008_1000_0000, 0x0000_0010_0800_0000 };
}

fn gen(board: [2]u64, comptime dir: u6) u64 {
    var x = board[0];
    var y = board[0];
    var z = board[1] & comptime switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1, 7 => 0x7E7E_7E7E_7E7E_7E7E,
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        x |= z & (x << d);
        y |= (z << dir & y) >> d;
        z &= z << d;
    }
    return (x ^ board[0]) << dir | (y ^ board[0]) >> dir;
}

pub fn moves(board: [2]u64) u64 {
    var ret: u64 = 0;
    inline for (.{ 1, 7, 8, 9 }) |i|
        ret |= gen(board, i);
    return ret & ~board[0] & ~board[1];
}

const pdep = @import("./intrinsic.zig").pdep;
const pext = @import("./intrinsic.zig").pext;

const MASK = @import("lut/mask.zig").MASK;
const INDEX = @import("lut/index.zig").INDEX;
const RESULT = @import("lut/test.zig").known;

pub fn move(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    comptime var i = 0;
    inline while (i < 4) : (i += 1)
        ret |= pdep(RESULT[
            @as(u64, INDEX[place][i]) * 32 + pext(board[0], MASK[place][i][0]) * 64 + pext(board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
    return ret;
}
