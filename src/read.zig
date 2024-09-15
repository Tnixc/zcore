const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");
const s = utils.StrToU8;

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
        linestr.trim(&utils.whitelist);

        if (linestr.includesLiteral(";")) { // remove comments
            const char = linestr.find(";").?;
            linestr = try linestr.substr(0, char);
            linestr.trim(&utils.whitelist);
        }

        if (linestr.len() == 0) {
            continue; // empty line
        }

        if (linestr.endsWith(":")) { // label
            const label = try linestr.substr(0, linestr.len() - 1);
            std.debug.print("line {d}: LABEL: {s}\n", .{ index, label.str() });
            try label_map.put(label, index);
        } else { // instruction
            std.debug.print("line {d}: {s}\n", .{ index, linestr.str() });
            linestr.toLowercase();
            // FORMAT: OP DEST,SRC1,SRC2

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
            // std.debug.print("res: {any}", .{lineToMachineCode(tokens)});
            _ = try lineToMachineCode(tokens, &label_map);
        }
        index += 1;
    }

    return instructions.toOwnedSlice();
}

fn lineToMachineCode(line: [4]String, labels: *std.AutoHashMap(String, usize)) !u16 {
    const op = line[0];
    var opcode: u4 = 0b0000;
    var dest: u4 = 0b0000;
    // var src1: u4 = 0b0000;
    // var src2: u4 = 0b0000;
    _ = labels;
    if (std.mem.eql(u8, op.str(), "load")) {
        opcode = 0b0001;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "store")) {
        opcode = 0b0010;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "add")) {
        opcode = 0b0011;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "sub")) {
        opcode = 0b0100;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "and")) {
        opcode = 0b0101;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "or")) {
        opcode = 0b0110;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "not")) {
        opcode = 0b0111;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "jump")) {
        opcode = 0b1000;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "jumpz")) {
        opcode = 0b1001;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "halt")) {
        opcode = 0b1010;
    } else if (std.mem.eql(u8, op.str(), "in")) {
        opcode = 0b1011;
        dest = try parseRegister(line[1]);
    } else if (std.mem.eql(u8, op.str(), "out")) {
        opcode = 0b1100;
        dest = try parseRegister(line[1]);
    } else {
        return error.InvalidOpcode;
    }
    const opS = try utils.zeroPad(u4, opcode);
    const destS = try utils.zeroPad(u4, dest);
    std.debug.print("opcode: {s}\n", .{opS});
    std.debug.print("  dest: {s}\n", .{destS});
    return 0;
}

fn parseRegister(reg: String) !u4 {
    var regcode = try reg.clone();
    var isPointer = false;
    if (regcode.startsWith("[") and regcode.endsWith("]")) {
        isPointer = true;
        regcode.trimStart("[");
        regcode.trimEnd("]");
    }
    var res: u4 = 0;
    if (std.mem.eql(u8, regcode.str(), "r0")) {
        res = 0;
    } else if (std.mem.eql(u8, regcode.str(), "r1")) {
        res = 1;
    } else if (std.mem.eql(u8, regcode.str(), "r2")) {
        res = 2;
    } else if (std.mem.eql(u8, regcode.str(), "r3")) {
        res = 3;
    } else if (std.mem.eql(u8, regcode.str(), "r4")) {
        res = 4;
    } else if (std.mem.eql(u8, regcode.str(), "r5")) {
        res = 5;
    } else if (std.mem.eql(u8, regcode.str(), "r6")) {
        res = 6;
    } else if (std.mem.eql(u8, regcode.str(), "r7")) {
        res = 7;
    } else {
        return error.InvalidRegister;
    }
    if (isPointer) {
        res = 0b1000 + res;
    }
    return res;
}
