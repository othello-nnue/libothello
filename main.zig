const print = @import("std").debug.print;
const game = @import("game").debug.print;

pub fn main() void {
    var board = game.init();
    var numpass = 0;
    while(true){
        var t = game.moves(board);
        if(t == 0){
            numpass += 1;
            var temp = board;
            board = .{temp[1], temp[0]};
            continue;
        }
        print
        if( board[0] |board[1] = 0xFFFF_FFFF_FFFF_FFFF)
            break;
        
        
    }
}