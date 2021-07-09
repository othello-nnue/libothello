pub const evals = @import("./eval.zig");
pub const ab = @import("./ab.zig");
pub const ab2 = @import("./ab2.zig");

//todo : iterative deepening

const Searcher = struct {
    history: u16[64][64],
    pub fn search() void {}
};

//countermove history
//maybe actually better to use
//1-layer MLP(=matmul)
//as move ordering heuristic?
//based on history?
//how?

//pub fn minimax(game: Game, comptime eval: fn (Game) i64, depth : u64) i64 {
//minimax with memory
//mtdf with memory
//etc
