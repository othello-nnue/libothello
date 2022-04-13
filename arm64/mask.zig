const mul = @import("utils").mul;
const fill = @import("utils").fill;
const make = @import("utils").make_array;

fn mask(pos: u6, comptime dir: u6) u64 {
    const t = @as(u64, 1) << pos;
    return fill(t, dir) & -%t << 1;
}

fn _mask(pos: u6) @Vector(4, u64) {
    return .{ mask(pos, 1), mask(pos, 8), mask(pos, 9), mask(pos, 7) };
}

pub const MASK = make(@Vector(4, u64), _mask);
