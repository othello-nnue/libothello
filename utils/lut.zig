const std = @import("std");

// make lut array from given function
pub fn make_array(comptime T: type, comptime func: fn (u6) T) [64]T {
    @setEvalBranchQuota(10000);
    var ret: [64]T = undefined;
    for (ret) |*m, i|
        m.* = func(@intCast(u6, i));
    return ret;
}

pub fn lut_type(comptime t: type) type {
    comptime var x = @typeInfo(t).Fn.return_type.?;
    inline for (@typeInfo(t).Fn.args) |arg| {
        const arg_type = @typeInfo(arg.arg_type.?).Int;
        std.debug.assert(arg_type.signedness == .unsigned);
        x = [1 << arg_type.bits]x;
    }
    return x;
}
