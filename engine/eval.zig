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
    return @as(i64, @popCount(u64, game.board[0] | game.moves())) - @popCount(u64, game.board[1]);
}
