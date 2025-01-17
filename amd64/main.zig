const pdep = @import("intrinsic.zig").pdep;
const pext = @import("intrinsic.zig").pext;

const MASK = @import("mask.zig").MASK;
const INDEX = @import("index.zig").INDEX;
const RESULT = @import("result.zig").RESULT;

pub fn flip(board: [2]u64, place: u6) u64 {
    var ret: u64 = 0;
    comptime var i = 0;
    inline while (i < 4) : (i += 1)
        ret |= pdep(RESULT[
            @as(u64, INDEX[place][i]) * 32 + pext(board[0], MASK[place][i][0]) * 64 + pext(board[1], MASK[place][i][1])
        ], MASK[place][i][1]);
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
