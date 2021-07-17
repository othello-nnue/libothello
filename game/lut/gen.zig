const print = @import("std").debug.print;
pub fn main() void {
    const res = @import("./result.zig").result();
    print("{any}", .{res});
}
