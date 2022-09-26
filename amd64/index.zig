const min = @import("std").math.min;
pub const HELPER = [8]u9{ 0, 0, 0o200, 0o201, 0o300, 0o301, 0o401, 0o400 };
pub const INDEX = @import("utils").make_array([4]u9, index);

fn index(pos: u6) [4]u9 {
    const a = @truncate(u3, pos);
    const b = @truncate(u3, pos >> 3);
    return .{
        HELPER[a],
        HELPER[b],
        HELPER[min(a, b)],
        0,
    };
}
