const std = @import("std");
const ts = @import("tree_sitter");
const Allocator = std.mem.Allocator;

extern fn tree_sitter_akbs() callconv(.C) *ts.Language;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const lang = tree_sitter_akbs();
    defer lang.destroy();

    const parser = ts.Parser.create();
    defer parser.destroy();
    try parser.setLanguage(lang);

    const src_buffer = "Hello $(user)! Hello again $(user)! How about a third hello for $(user)?";
    const tree = try parser.parseBuffer(src_buffer, null, null);
    defer tree.destroy();

    const root_node = tree.rootNode();

    var tc = ts.TreeCursor.create(root_node);
    defer tc.destroy();

    // check for errors
    var qc = ts.QueryCursor.create();
    defer qc.destroy();

    var error_offset: u32 = 0;
    const error_query = try ts.Query.create(lang, "(ERROR) @error-node", &error_offset);
    defer error_query.destroy();

    qc.exec(error_query, root_node);
    if (qc.nextMatch()) |match| {
        std.log.err("Command failed to parse: syntax error at position {d}", .{match.captures[0].node.startByte()});
        return;
    }

    // go to the first child to start parsing, otherwise it's going to include the whole input
    if (!tc.gotoFirstChild()) {
        std.log.err("Input node has no children", .{});
        return;
    }

    // set up our output buffer as an ArrayList
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    var offset: i32 = 0;
    try output.appendSlice(src_buffer);

    // get children until no more
    // back off until new sibling
    // move to sibling
    // repeat

    outer: while (true) {
        const node_type = tc.currentNode().type();

        if (tc.currentNode().isMissing()) {
            std.log.err("missing {s} at pos {d}", .{ node_type, tc.currentNode().startByte() });
            return;
        }

        if (std.mem.eql(u8, tc.currentNode().type(), "variable")) {
            const child_name = src_buffer[tc.currentNode().childByFieldName("name").?.startByte()..tc.currentNode().childByFieldName("name").?.endByte()];
            if (std.mem.eql(u8, child_name, "user")) {
                try bw.flush();
                const new = "demize";
                const start_pos: i32 = @as(i32, @intCast(tc.currentNode().startByte())) + offset;
                const end_pos: i32 = @as(i32, @intCast(tc.currentNode().endByte())) + offset;
                const token_len: i32 = end_pos - start_pos;
                if (start_pos < 0 or end_pos < 0) {
                    std.debug.panic("negative offset too large", .{});
                }
                try output.replaceRange(@intCast(start_pos), @intCast(token_len), new);
                offset = offset + @as(i32, @intCast(new.len)) - token_len;
                try bw.flush();
                // go to the last child, we're done with this node entirely
                _ = tc.gotoLastChild();
            }
        }

        if (!tc.gotoFirstChild()) {
            while (!tc.gotoNextSibling()) {
                if (!tc.gotoParent()) {
                    break :outer;
                }
            }
        }
    }

    try stdout.print(" in: {s}\n", .{src_buffer});
    try stdout.print("out: {s}\n", .{output.items});
    try bw.flush();
}
