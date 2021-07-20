const mul = @import("utils").mul;
const fill = @import("utils").fill;

fn mask(pos: u6, comptime dir: u6) [2]u64 {
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
    return [4][2]u64{ mask(pos, 1), mask(pos, 8), mask(pos, 9), mask(pos, 7) };
}

pub const MASK = @import("utils").make_array([4][2]u64, _mask);
