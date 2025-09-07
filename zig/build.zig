const std = @import("std");
const Target = std.Target;
const Feature = Target.riscv.Feature;

const XLEN = 32;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.generic_rv32 },
        .cpu_features_add = Target.riscv.featureSet(&[_]Feature{
            .a,
            .m,
        }),
        .os_tag = .freestanding,
        .abi = .none, // .eabi
    };

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "_foo",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
    });

    exe.addIncludePath(b.path("include/"));
    exe.addCSourceFiles(.{
        .files = &.{ "c/ulib.c", "c/umalloc.c", "c/printf.c" },
        .flags = &.{"-std=c23"},
    });

    exe.setLinkerScript(b.path("src/linker.ld"));
    exe.addAssemblyFile(b.path("c/usys.S"));
    b.installArtifact(exe);
}
