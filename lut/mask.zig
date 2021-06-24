const RIGHT: u64 = 0x7F7F_7F7F_7F7F_7F7F;
const LEFT: u64 = 0xFEFE_FEFE_FEFE_FEFE;
const MID: u64 = 0x00FF_FFFF_FFFF_FF00;
const CENTER: u64 = MID & LEFT & RIGHT; //0x007E_7E7E_7E7E_7E00

fn mask(pos: u6) [4][2]u64 {
    var ret: [4][2]u64 = undefined;
    const t = @as(u64, 1) << pos;
    const a = t | t << 8 | t >> 8;
    const square = a | (a << 1 & LEFT) | (a >> 1 & RIGHT);

    for (ret) |*re, _i| {
        const i = @intCast(u2, _i);
        var r: u64 =
            switch (i) {
            0 => 0x0000_0000_0000_00FF,
            1 => 0x0101_0101_0101_0101,
            2 => 0x0000_0000_0000_0080,
            3 => 0x0000_0000_0000_0001,
        };
        while (r & t == 0)
            r = switch (i) {
                0 => r << 8,
                1 => r << 1,
                2 => r >> 1 & RIGHT | r << 8,
                3 => r << 1 & LEFT | r << 8,
            };
        re.*[0] = r & ~square;
        re.*[1] = r & ~t & switch (i) {
            0 => RIGHT & LEFT,
            1 => MID,
            2, 3 => CENTER,
        };
    }
    return ret;
}

pub const MASK: [64][4][2]u64 = init: {
    @setEvalBranchQuota(10000);
    var ret: [64][4][2]u64 = undefined;
    for (ret) |*m, i|
        m.* = mask(@intCast(u6, i));
    break :init ret;
};

fn mask2() [64][4][2]u64 {
    var ret: [64][4][2]u64 = undefined;
    var i:u3 = 0;
    while(true){
        
    }
}