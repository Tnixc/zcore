const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");
const parse = @import("parse.zig");

const String = @import("string").String;

pub fn readFileToMachineCode(filename: []const u8) ![]const u16 {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var instructions = std.ArrayList(u16).init(std.heap.page_allocator);
    defer instructions.deinit();

    var buf: [256]u8 = undefined;

    var index: usize = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var label_map = std.AutoHashMap(String, usize).init(arena.allocator());

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linestr = String.init(arena.allocator());
        try linestr.setStr(line);

        // preprocessing
        linestr.trim(&utils.whitelist);

        if (linestr.includesLiteral(";")) { // remove comments
            const char = linestr.find(";").?;
            linestr = try linestr.substr(0, char);
            linestr.trim(&utils.whitelist);
        }

        if (linestr.len() == 0) {
            continue; // empty line
        }

        if (linestr.endsWith(":")) { // line is label
            const label = try linestr.substr(0, linestr.len() - 1);
            std.debug.print("line {d}: LABEL: {s}\n", .{ index, label.str() });
            try label_map.put(label, index);
        } else { // line is instruction
            std.debug.print("line {d}: {s}\n", .{ index, linestr.str() });
            linestr.toLowercase();

            // FORMAT: OP DEST,SRC1,SRC2
            // tokenize
            var tokens = [4]String{ undefined, undefined, undefined, undefined };
            const tokens1 = try linestr.splitAllToStrings(" ");
            tokens[0] = tokens1[0];

            var i: usize = 1;
            while (i < tokens1.len) : (i += 1) {
                const token = tokens1[i];
                if (token.len() > 0) {
                    tokens[i] = token;
                }
            }

            i = 0;
            while (i < 4) : (i += 1) {
                if (tokens[i].len() > 0) {
                    tokens[i].trim(&utils.whitelist);
                    tokens[i].trim(",");
                }
            }

            // const thisRes = try lineToMachineCode(tokens, &label_map);
            _ = try lineToMachineCode(tokens, &label_map);
        }
        index += 1;
    }

    return instructions.toOwnedSlice();
}
/// Convert a line of assembly code to a machine code instruction
fn lineToMachineCode(line: [4]String, labels: *std.AutoHashMap(String, usize)) !u16 {
    const lineRes = try parse.parseLine(line, labels);
    _ = lineRes;
    return 0;
}
