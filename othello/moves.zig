//for AVX512 rotate might be slightly faster
fn shift(x: u64, comptime y: i7) u64 {
    if (y > 0) 
        return x >> y;
    else 
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
