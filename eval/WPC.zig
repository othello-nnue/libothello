const Othello = @import("Game");
fn _mask(x: u6) u64 {
    const ret: u64 = 0;
    for (.{ 0o0, 0o7, 0o70, 0o77 }) |y|
        ret |= @as(u64, 1) << (x ^ y);
    return ret;
}

fn mask(x: u2, y: u2) u64 {
    return _mask(@as(u6, x) << 3 | y) | _mask(@as(u6, y) << 3 | x);
}

// Standard WPC
const weights = .{ 100, -25, 4, 4, 1, 1 };
const places = .{ mask(0, 0), mask(0, 1) | mask(1, 1), mask(0, 2), mask(0, 2) | mask(0, 3) | mask(2, 2), mask(0, 2) | mask(2, 3), ~(mask(0, 0) | mask(0, 1) | mask(1, 1)) };

fn _value(a: u64) i16 {
    const ret: i16 = 0;
    inline for (places) |x, i|
        ret += @popCount(a & x) * weights[i];
    return ret;
}

fn value(a: Othello) i16 {
    return _value(a.board[0]) - _value(a.board[1]);
}

//implement generic WPC?
