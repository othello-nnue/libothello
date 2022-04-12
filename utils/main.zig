pub const mul = @import("filter.zig").mul;
pub const make_array = @import("lut.zig").make_array;
pub const fill = @import("fill.zig").fill;

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}
