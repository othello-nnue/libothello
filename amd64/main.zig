const pdep = @import("intrinsic.zig").pdep;
const pext = @import("intrinsic.zig").pext;

const MASK = @import("mask.zig").MASK;
const INDEX = @import("index.zig").INDEX;
const RESULT = @import("test.zig").known;
// const RESULT = @import("result.zig").result();

pub fn flip(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    comptime var i = 0;
    inline while (i < 2) : (i += 1)
        ret |= pdep(RESULT[
            @as(u64, INDEX[place][i]) * 32 + pext(board[0], MASK[place][i][0]) * 64 + pext(board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
    ret |= pdep(RESULT[
            @as(u64, INDEX[place][2]) * 32 | pext(board[0], MASK[place][i][0]) * 64 + pext(board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
    ret |= (((board[0] & MASK[place][3][0]) *% 0x05_0005) >> 9) & board[1] & MASK[place][3][0];
    return ret;
}

pub fn prefetch() void {
    @prefetch(&MASK, .{});
    @prefetch(&INDEX, .{});
    @prefetch(&RESULT, .{});
}

test {
    _ = @import("test.zig");
    _ = @import("index.zig");
}
