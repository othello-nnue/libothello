const min = @import("std").math.min;
const max = @import("std").math.max;
pub const HELPER = [_]u9{ 0o000, 0o000, 0o200, 0o201, 0o300, 0o301, 0o401, 0o400, 0o600, 0o601, 0o700, 0o701 };
pub const INDEX = @import("utils").make_array([4]u9, index);

fn index(pos: u6) [4]u9 {
    const a = @truncate(u3, pos);
    const b = @truncate(u3, pos >> 3);
    var c = min(b, max(a, 7 - a));
    if (a == 3 or a == 4) {
        c = a + if (b > 3) 7 else 5;
    }
    return .{
        HELPER[a],
        HELPER[b],
        HELPER[c],
        0,
    };
}
