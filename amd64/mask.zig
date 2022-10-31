pub const MASK = @import("utils").make_array([4][2]u64, _mask);

const mul = @import("utils").mul;
const fill = @import("utils").fill;

fn mask(pos: u6, comptime dir: u6) @Vector(2, u64) {
    const t = @as(u64, 1) << pos;
    const a = t | t << 8 | t >> 8;
    const b = a | (a << 1 & mul(0xFF, 0xFE)) | (a >> 1 & mul(0xFF, 0x7F));

    const r = fill(t, dir);
    return .{ r & ~b, r & ~t & switch (dir) {
        1 => mul(0xFF, 0x7E),
        8 => mul(0x7E, 0xFF),
        7, 9 => mul(0x7E, 0x7E),
        else => unreachable,
    } };
}

fn _mask(pos: u6) [4][2]u64 {
    // we don't support this case
    // zero for faster error finding
    if (@truncate(u1, mul(0x18, 0x18) >> pos) != 0) {
        return [_][2]u64{.{ 0, 0 }} ** 4;
    }

    var t = ~@as(u64, 0);
    const u = @truncate(u3, pos);
    if (u == 2 and pos >= 18) {
        t = mul(0xFF, 0xF8);
    } else if (u == 5 and pos <= 45) {
        t = mul(0xFF, 0x1F);
    } else if (pos == 19 or pos == 20) {
        t = mul(0xF8, 0xFF);
    } else if (pos == 43 or pos == 44) {
        t = mul(0x1F, 0xFF);
    }

    const temp = mask(pos, 7) | mask(pos, 9);
    const tt = @splat(2, t);
    return .{ mask(pos, 1), mask(pos, 8), temp & tt, temp & ~tt };
}
