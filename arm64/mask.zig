const mul = @import("utils").mul;
const fill = @import("utils").fill;

fn mask(pos: u6, comptime dir: u6) u64 {
    const t = @as(u64, 1) << pos;
    return fill(t, dir) & -%t << 1;
}

fn _mask(pos: u6) [4]u64 {
    return [4]u64{ mask(pos, 1), mask(pos, 8), mask(pos, 9), mask(pos, 7) };
}

pub const MASK = @import("utils").make_array([4]u64, _mask);
