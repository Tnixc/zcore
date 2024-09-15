const std = @import("std");
const main = @import("main.zig");
const util = @import("util.zig");
const String = @import("string").String;
const s = util.StrToU8;
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
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // var isInstruction = false;
        // std.debug.print("isInstruction: {any}\n", .{isInstruction});
        std.debug.print("{s}\n", .{line});
        var isLabel = false;
        if (line[line.len - 1] == ':') {
            isLabel = true;
        }
        std.debug.print("isLabel: {any}\n", .{isLabel});
        index += 1;
    }

    return instructions.toOwnedSlice();
}
