const std = @import("std");

/// make lut array from given function
/// @return `func(i) == @retval[i]`
pub fn make_array(comptime T: type, comptime func: fn (u6) T) [64]T {
    @setEvalBranchQuota(10000);
    var ret: [64]T = undefined;
    for (ret) |*m, i|
        m.* = func(@intCast(u6, i));
    return ret;
}
