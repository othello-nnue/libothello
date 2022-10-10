const bench = @import("bench");
const tests = @import("perft");

pub fn main() anyerror!void {
    // tests.print_avx512_usage();
    _ = tests.perft(.{}, 12);
}
