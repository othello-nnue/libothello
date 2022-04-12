const std = @import("std");

test {
    const isa = @import("builtin").target.cpu;
    const features = isa.model.*.features;
    //features.addFeature(@enumToInt(std.Target.x86.Feature.avx512f));

    //(@enumToInt(std.Target.x86.Feature.avx512f));
    const has = std.Target.x86.featureSetHas(features, .avx512f);
    //const avx512 = @import("std").Target.x86.cpu.x86_64_v4.features;
    //const has = features.isSuperSetOf(avx512);
    std.debug.print("\n{}\n{}\n{}\n{}\n", .{ isa, features, has, has });
}
