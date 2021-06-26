const std = @import("std");
const othello = @import("othello");

const os = std.os;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const VTIME = 5;
const VMIN = 6;

var x: u3 = 0;
var y: u3 = 0;
var z: u1 = 0;

var game = othello.init();

pub fn main() anyerror!void {
    const original_termios = try rawmode();
    defer os.tcsetattr(stdin.handle, .FLUSH, original_termios) catch {};

    try stdout.writeAll("\x1B[?25l\x1B[2J"); //hide cursor, clear screen
    defer stdout.writeAll("\x1B[?25h") catch {}; //show cursor

    try render();
    var buff: [1]u8 = undefined;
    while (true) {
        _ = try stdin.read(&buff);
        switch (buff[0]) {
            'q' => return,
            'D', 'H', 'h', 'a' => x -%= 1,
            'C', 'L', 'l', 'd' => x +%= 1,
            'B', 'J', 'j', 's' => y +%= 1,
            'A', 'K', 'k', 'w' => y -%= 1,
            ' ' => {
                const t = @as(u6, y) * 8 + x;
                if (@as(u64, 1) << t & (game[0] | game[1]) != 0) continue;
                const u = othello.move(game, t);
                if (u == 0) continue;
                const temp = game;
                game = .{ temp[1] ^ u, temp[0] ^ u ^ (@as(u64, 1) << t) };
                z ^= 1;
            },
            else => continue,
        }
        try render();
    }
}

//rawmode but with OPOST
fn rawmode() !os.termios {
    var termios = try os.tcgetattr(stdin.handle);
    var original_termios = termios;

    //man 3 termios
    termios.iflag &= ~@as(
        os.tcflag_t,
        os.IGNBRK | os.BRKINT | os.PARMRK | os.ISTRIP |
            os.INLCR | os.IGNCR | os.ICRNL | os.IXON,
    );
    termios.lflag &= ~@as(
        os.tcflag_t,
        os.ECHO | os.ECHONL | os.ICANON | os.ISIG | os.IEXTEN,
    );
    termios.cflag &= ~@as(os.tcflag_t, os.CSIZE | os.PARENB);
    termios.cflag |= os.CS8;

    termios.cc[VMIN] = 1;
    termios.cc[VTIME] = 0;

    try os.tcsetattr(stdin.handle, .FLUSH, termios);
    return original_termios;
}

const bytes = ".ox*@OX@";

fn render() !void {
    var out = ("\x1B[1;1H" ++ ("." ** 8 ++ "\n") ** 8).*;
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

        if (@as(u6, y) * 8 + x == i) k += 4;

        out[i + "\x1B[1;1H".len + (i >> 3)] = bytes[k];
    }
    try stdout.writeAll(&out);
}
