const std = @import("std");
const zbox = @import("zbox");
const othello = @import("othello");

pub fn main() anyerror!void {
    const alloc = std.heap.page_allocator;

    // initialize the zbox with stdin/out
    try zbox.init(alloc);
    defer zbox.deinit();

    //try zbox.handleSignalInput();
    try zbox.cursorHide();
    defer zbox.cursorShow() catch {};

    var game = othello.init();
    var output = try zbox.Buffer.init(alloc, 8, 8);

    var x: u3 = 0;
    var y: u3 = 0;

    defer output.deinit();
    while (try zbox.nextEvent()) |e| {
        switch (e) {
            .left => x -%= 1,
            .right => x +%= 1,
            .down => y +%= 1,
            .up => y -%= 1,
            .other => |data| {
                const eql = std.mem.eql;
                if (eql(u8, " ", data)) {
                    const t = @as(u6, x) * 8 + y;
                    const u = othello.move(gamet, t);
                    if (u != 0) {
                        const temp = game;
                        game = .{ temp[1] ^ u, temp[0] ^ u ^ (@as(u64, 1) << t) };
                    }
                }
            },

            .escape => return,
            else => {},
        }
        output.clear();
        output.cellRef(y, x).char = 'a';
        {
            const t = othello.moves(game);
            var i: u7 = 0;
            while (i < 64) : (i += 1) {
                const j = @as(u64, 1) << @intCast(u6, i);
                const k = @truncate(u3, i);
                const l = @truncate(u3, i >> 3);
                if (game[0] & j != 0) {
                    output.cellRef(k, l).char = 'O';
                } else if (game[1] & j != 0) {
                    output.cellRef(k, l).char = 'X';
                } else if (t & j != 0) {
                    output.cellRef(k, l).char = '*';
                }
            }
        }

        try zbox.push(output);
    }
}
