const std = @import("std");
const Game = @import("othello");
const engine = @import("engine");

const os = std.os;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const VTIME = 5;
const VMIN = 6;

var x: u3 = 0;
var y: u3 = 0;
var z: u1 = 0;

var seq = [_]u8{255} ** 64;

var game = Game{};
const eng = engine.ab{.depth = 8, .eval = engine.evals.good};

pub fn main() anyerror!void {
    const original_termios = try rawmode();
    defer os.tcsetattr(stdin.handle, .FLUSH, original_termios) catch {};

    try stdout.writeAll("\x1B[?25l\x1B[2J"); //hide cursor, clear screen
    defer stdout.writeAll("\x1B[?25h") catch {}; //show cursor

    try render();
    var buff: [1]u8 = undefined;
    while (!game.end()) {
        if (game.moves() == 0) {
            game = game.pass();
            z ^= 1;
        }
        if (z == 1) {
            const move = eng.move(game);
            seq[@popCount(u64, game.board[0] | game.board[1])] = move;
            game = game.move(move).?;
            z ^= 1;
            try render();
            continue;
        }
        try render();
        _ = try stdin.read(&buff);
        switch (buff[0]) {
            'q' => return,
            'D', 'H', 'h', 'a' => x -%= 1,
            'C', 'L', 'l', 'd' => x +%= 1,
            'B', 'J', 'j', 's' => y +%= 1,
            'A', 'K', 'k', 'w' => y -%= 1,
            ' ' => {
                if (game.move(@as(u6, y) * 8 + x)) |newgame| {
                    seq[@popCount(u64, game.board[0] | game.board[1])] = @as(u6, y) * 8 + x;
                    game = newgame;
                    z ^= 1;
                } else continue;
            },
            else => continue,
        }
    }
    var u = game.score();
    if (z == 1) u = -u;
    switch (u) {
        1...32 => try stdout.writeAll("O wins"),
        0 => try stdout.writeAll("Draw"),
        -32...-1 => try stdout.writeAll("X wins"),
        else => unreachable,
    }

    const writer = stdout.writer();
    for (seq) |i| {
        try writer.print("\t{}", .{i});
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
    var moves = game.moves();

    var i: u7 = 0;
    while (i < 64) : (i += 1) {
        const j = @as(u64, 1) << @intCast(u6, i);
        var k: u3 = 0;
        if (game.board[z] & j != 0) {
            k = 1;
        } else if (game.board[~z] & j != 0) {
            k = 2;
        } else if (moves & j != 0)
            k = 3;
        if (@as(u6, y) * 8 + x == i) k += 4;

        out[i + "\x1B[1;1H".len + (i >> 3)] = bytes[k];
    }
    try stdout.writeAll(&out);
}
