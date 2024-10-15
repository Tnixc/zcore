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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var label_map = std.StringHashMap(usize).init(arena.allocator());

    var line_index: usize = 0;
    var index: usize = 0;

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
            std.debug.print("line {d}| LABEL: {s}\n", .{ line_index, label.str() });
            label_map.put(label.str(), index) catch return error.LabelPutError;
        } else { // line is instruction
            std.debug.print("line {d}| index: {d} | {s}\n", .{ line_index, index, linestr.str() });
            linestr.toLowercase();

            // FORMAT: OP DEST,SRC1,SRC2
            // tokenize
            var tokens = [_]String{undefined} ** 4;
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
            try instructions.append(try parse.parseLine(tokens, &label_map));
            index += 1;
        }
        line_index += 1;
    }
    return instructions.toOwnedSlice();
}
