const othello = @import("othello");

pub fn zero(game: othello.Game) i64 {
    _ = game;
    return 0;
}

//pub fn random
//pub fn hash

pub fn mobility(game: othello.Game) i64 {
    return @popCount(u64, game.moves());
}

pub fn count(game: othello.Game) i64 {
    return @popCount(u64, game.board[0]) - @popCount(u64, game.board[1]);
}
