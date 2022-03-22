pub const pdep = @import("utils/intrinsic.zig").pdep;
pub const pext = @import("utils/intrinsic.zig").pext;
pub const mul = @import("utils/filter.zig").mul;
pub const make_array = @import("utils/lut.zig").make_array;
pub const fill = @import("utils/fill.zig").fill;

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}