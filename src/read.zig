const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");
const String = @import("string").String;

const s = utils.StrToU8;
const Op = main.Op;

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
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var linestr = String.init(arena.allocator());
        try linestr.concat(line);
        linestr.trim(&utils.whitelist);

        if (linestr.includesLiteral(";")) {
            const char = linestr.find(";").?;
            linestr.clear();
            try linestr.concat(line[0..char]);
            linestr.trim(&utils.whitelist);
        }

        if (linestr.len() == 0) {
            continue;
        }
        
        var isLabel = false;
        
        std.debug.print("line {any}: {s}\n", .{ index, linestr.str() });
        index += 1;
    }

    return instructions.toOwnedSlice();
}
