pub const MASK = @import("lut/mask.zig").MASK;
pub const INDEX = @import("lut/index.zig").INDEX;

//pub const RESULT: [0x3800]u8 = undefined; //result();
pub const RESULT: [0x3800]u8 = @import("lut/test.zig").known;
