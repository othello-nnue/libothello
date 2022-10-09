const testing = @import("std").testing;
const print = @import("std").debug.print;
// test "result test" {
//     const res = @import("result.zig").RESULT;
//     try testing.expectEqualSlices(u6, &res, &known);
//     try testing.expectEqual(0x3000, @sizeOf(@TypeOf(res)));
//     try testing.expectEqual(0x3000, @sizeOf(@TypeOf(known)));
// }

test "range test" {
    const MASK = @import("mask.zig").MASK;
    for (MASK) |i|
        for (i) |j|
            for (j) |k|
                testing.expect(@popCount(k) <= 6) catch {
                    print("{} \n", .{k});
                    unreachable;
                };
}

test "size test" {
    const INDEX = @import("index.zig").INDEX;
    try testing.expectEqual(2 * 4 * 64, @sizeOf(@TypeOf(INDEX)));
}
