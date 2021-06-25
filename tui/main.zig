const std = @import("std");
const zbox = @import("zbox");
const othello = @import("othello");

const bytes = ".ox*@OX@";

var x: u3 = 0;
var y: u3 = 0;
var z: u1 = 0;

var game = othello.init();

pub fn main() anyerror!void {
    const alloc = std.heap.page_allocator;

    // initialize the zbox with stdin/out
    try zbox.init(alloc);
    defer zbox.deinit();

    //try zbox.handleSignalInput();
    try zbox.cursorHide();
    defer zbox.cursorShow() catch {};

    var output = try zbox.Buffer.init(alloc, 8, 8);
    defer output.deinit();

    render(&output);
    try zbox.push(output);

    while (try zbox.nextEvent()) |e| {
        switch (e) {
            .escape => return,
            .tick => continue,
            .left => x -%= 1,
            .right => x +%= 1,
            .down => y +%= 1,
            .up => y -%= 1,
            .other => |data| {
                const eql = std.mem.eql;
                if (eql(u8, " ", data)) {
                    const t = @as(u6, x) * 8 + y;
                    if (@as(u64, 1) << t & (game[0] | game[1]) != 0) continue;
                    const u = othello.move(game, t);
                    if (u != 0) {
                        const temp = game;
                        game = .{ temp[1] ^ u, temp[0] ^ u ^ (@as(u64, 1) << t) };
                        z ^= 1;
                    }
                } else continue;
            },
        }
        render(&output);
        try zbox.push(output);
    }
}

fn render(output: *zbox.Buffer) void {
    output.clear();
    const t = othello.moves(game);
    var i: u7 = 0;
    while (i < 64) : (i += 1) {
        const j = @as(u64, 1) << @intCast(u6, i);
        var k: u3 = 0;
        if (game[z] & j != 0) {
            k = 1;
        } else if (game[~z] & j != 0) {
            k = 2;
        } else if (t & j != 0)
            k = 3;

        if (@as(u6, x) * 8 + y == i) k += 4;

        output.*.cellRef(@truncate(u3, i), @truncate(u3, i >> 3)).char = bytes[k];
    }
}
