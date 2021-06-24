pub fn init() [2]u64 {
    return [2]u64{ 0x0000_0008_1000_0000, 0x0000_0010_0800_0000 };
}

//for AVX512 rotate might be slightly faster
fn shift(x: u64, comptime y: i7) u64 {
    if (y > 0)
        return x >> y;
    return x << -y;
}

fn gen(board: [2]u64, comptime dir: i7) u64 {
    var x = board[0];
    var y = board[1] & comptime switch (@mod(dir, 8)) {
        0 => 0xFFFF_FFFF_FFFF_FFFF,
        1, 7 => 0x7E7E_7E7E_7E7E_7E7E,
        else => unreachable,
    };
    inline for (.{ dir, dir * 2, dir * 4 }) |d| {
        x |= y & shift(x, d);
        y &= shift(y, d);
    }
    return shift(x ^ board[0], dir);
}

pub fn moves(board: [2]u64) u64 {
    var ret: u64 = 0;
    inline for (.{ -9, -8, -7, -1, 1, 7, 8, 9 }) |i|
        ret |= gen(board, i);
    return ret & ~board[0] & ~board[1];
}

const pdep = @import("./intrinsic.zig").pdep;
const pext = @import("./intrinsic.zig").pext;

const MASK = @import("./lut.zig").MASK;
const INDEX = @import("./lut.zig").INDEX;
const RESULT = @import("./lut.zig").RESULT;

pub fn move(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    comptime var i = 0;
    inline while (i < 4) : (i += 1)
        ret |= pdep(RESULT[
            @as(u64, INDEX[place][i]) * 32 + pext(board[0], MASK[place][i][0]) * 64 + pext(board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
    return ret;
}
