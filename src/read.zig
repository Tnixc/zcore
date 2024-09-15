const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");

const String = @import("string").String;

pub fn readtoMachineCode(filename: []const u8) ![]const u16 {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var instructions = std.ArrayList(u16).init(std.heap.page_allocator);
    defer instructions.deinit();
    var buf: [1024]u8 = undefined;

    var index: usize = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    var label_map = std.AutoHashMap(String, usize).init(arena.allocator());

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linestr = String.init(arena.allocator());
        try linestr.concat(line);
        linestr.trim(&utils.whitelist);
        if (linestr.includesLiteral(";")) {
            const char = linestr.find(";").?;
            linestr = try linestr.substr(0, char);
            linestr.trim(&utils.whitelist);
        }

        if (linestr.len() == 0) {
            continue;
        }

        if (linestr.endsWith(":")) {
            const label = try linestr.substr(0, linestr.len() - 1);
            std.debug.print("label: {s}\n", .{label.str()});

            try label_map.put(label, index);
        } else {
            std.debug.print("line {any}: {s}\n", .{ index, linestr.str() });
            index += 1;
        }
    }

    var map_iter = label_map.iterator();
    while (map_iter.next()) |entry| {
        std.debug.print("label: {s} at index {any}\n", .{ entry.key_ptr.str(), entry.value_ptr.* });
    }
    return instructions.toOwnedSlice();
}
