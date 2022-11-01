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

    const t: u64 = switch (pos) {
        2, 10, 53, 61 => 0,
        19, 20 => mul(0x07, 0xFF),
        43, 44 => mul(0xE0, 0xFF),
        else => switch (pos & 7) {
            2 => mul(0xFF, 0x07),
            5 => mul(0xFF, 0xE0),
            else => 0,
        },
    };
    const temp = mask(pos, 7) | mask(pos, 9);
    const tt = @splat(2, t);
    return .{ mask(pos, 1), mask(pos, 8), temp & ~tt, temp & tt };
}
