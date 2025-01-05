const std = @import("std");
const ts = @import("tree_sitter");

extern fn tree_sitter_akbs() callconv(.C) *ts.Language;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try stdout.print("starting...\n", .{});
    try bw.flush();

    const lang = tree_sitter_akbs();
    defer lang.destroy();

    const parser = ts.Parser.create();
    defer parser.destroy();
    try parser.setLanguage(lang);

    const tree = try parser.parseBuffer("Hello $(touser)! You're in a test!", null, null);
    defer tree.destroy();

    const node = tree.rootNode();
    std.debug.assert(std.mem.eql(u8, node.type(), "input"));

    try stdout.print("It works!!!\n", .{});
    try bw.flush();
}
