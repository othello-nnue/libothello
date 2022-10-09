pub const MASK = @import("utils").make_array([4][2]u64, _mask);

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
    const dummy = [2]u64{ 0, 0 };
    if (@truncate(u1, mul(0x18, 0x18) >> pos) != 0) {
        //we don't support this case, so output nonsense for early error detection
        return [_][2]u64{dummy} ** 4;
    } else {
        const temp1 = mask(pos, 7);
        const temp2 = mask(pos, 9);

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
        //long diagonals
        const diag = [2]u64{ (temp1[0] | temp2[0]) & t, (temp1[1] | temp2[1]) & t };
        //very short diagonals, flipping at most one)
        const short = [2]u64{ (temp1[0] | temp2[0]) & ~t, (temp1[1] | temp2[1]) & ~t };
        if (@popCount(short[0]) > 2 or @popCount(short[1]) > 2) {
            unreachable;
        }
        return .{ mask(pos, 1), mask(pos, 8), diag, short };
    }
}
