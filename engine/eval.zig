const Game = @import("othello");

pub fn zero(game: Game) i64 {
    _ = game;
    return 0;
}

//pub fn random
//pub fn hash

pub fn mobility(game: Game) i64 {
    return @popCount(u64, game.moves());
}

pub fn count(game: Game) i64 {
    return @popCount(u64, game.board[0]) - @popCount(u64, game.board[1]);
}

pub fn good(game: Game) i64 {
    return @as(i64, @popCount(u64, game.board[0] | game.moves())) - @popCount(u64, game.board[1]) - 1;
    //return good(game);
}

pub fn goods(game: Game) i8 {
    return @as(i8, @popCount(u64, game.board[0] | game.moves())) - @popCount(u64, game.board[1]);
}

//https://github.com/kartikkukreja/blog-codes/blob/master/src/Heuristic%20Function%20for%20Reversi%20(Othello).cpp
pub fn verygood(game: Game) i64 {
    _ = game;
    return 0;
}
