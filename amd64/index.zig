const min = @import("std").math.min;
pub const HELPER = [8]u9{ 0, 0, 0o200, 0o201, 0o300, 0o301, 0o401, 0o400 };
const HELPER_LEA = [8]u11{ 0, 0, 0o1000, 0o1004, 0o1400, 0o1404, 0o2004, 0o2000 };
pub const INDEX = @import("utils").make_array([4]u9, index);
pub const INDEX_LEA = @import("utils").make_array([4]u11, index_lea);

fn index(pos: u6) [4]u9 {
    const a = @truncate(u3, pos);
    const b = @truncate(u3, pos >> 3);
    return .{
        HELPER[a],
        HELPER[b],
        HELPER[min(a, b)],
        HELPER[min(7 - a, b)],
    };
}

fn index_lea(pos: u6) [4]u11 {
    const a = @truncate(u3, pos);
    const b = @truncate(u3, pos >> 3);
    return .{
        HELPER_LEA[a],
        HELPER_LEA[b],
        HELPER_LEA[min(a, b)],
        HELPER_LEA[min(7 - a, b)],
    };
}
