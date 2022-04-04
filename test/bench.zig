const bench = @import("bench");
const tests = @import("perft");

pub fn main() anyerror!void {
    try bench.benchmark(struct {
        pub const args = [_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
        pub const min_iterations = 1;
        pub fn perft(depth: usize) u64 {
            return tests.perft(.{}, depth);
        }
    });
}
