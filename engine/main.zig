pub const evals = @import("./eval.zig");
pub const ab = @import("./ab.zig");

//todo : iterative deepening

const Searcher = struct {
    history: u16[64][64],
    pub fn search() void {}
};

//countermove history

//pub fn minimax(game: Game, comptime eval: fn (Game) i64, depth : u64) i64 {
//minimax with memory
//mtdf with memory
//etc
