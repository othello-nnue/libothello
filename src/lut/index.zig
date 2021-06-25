const min = @import("std").math.min;
pub const HELPER = [8]u16{ 0, 0o200, 0o201, 0o300, 0o301, 0o400, 0o401, 0o500 };

fn index(pos: u6) [4]u16 {
    const a = @truncate(u3, pos);
    const b = @truncate(u3, pos >> 3);
    return [4]u16{
        HELPER[a],
        HELPER[b],
        HELPER[min(a, b)],
        HELPER[min(7 - a, b)],
    };
}

pub const INDEX: [64][4]u16 = init: {
    var ret: [64][4]u16 = undefined;
    for (ret) |*m, i|
        m.* = index(@intCast(u6, i));
    break :init ret;
};
