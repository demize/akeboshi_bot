const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "akeboshi_bot",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);

    const tree_sitter = b.dependency("tree_sitter", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("tree_sitter", tree_sitter.module(("tree_sitter")));

    const tree_sitter_akbs_builder = b.dependency("tree_sitter_akbs", .{}).builder;
    const tree_sitter_akbs = tree_sitter_akbs_builder.addStaticLibrary(.{
        .name = "tree-sitter-akbs",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    tree_sitter_akbs.addIncludePath(tree_sitter_akbs_builder.path("src"));
    tree_sitter_akbs.addCSourceFile(.{
        .file = tree_sitter_akbs_builder.path("src/parser.c"),
    });
    exe.linkLibrary(tree_sitter_akbs);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
