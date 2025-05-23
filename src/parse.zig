const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");

const String = @import("string").String;

pub fn parseLine(line: [4]String, labels: *std.StringHashMap(usize)) !u16 {
    var opcode: u4 = 0b0000;
    var dest: u4 = 0b0000;
    var vals: u8 = 0b0000_0000;
    const op = line[0];

    if (std.mem.eql(u8, op.str(), "set")) {
        opcode = 0b0000;
        dest = try parseRegister(line[1]);
        vals = try std.fmt.parseInt(u8, line[2].str(), 10);
    } else if (std.mem.eql(u8, op.str(), "load")) {
        opcode = 0b0001;
        dest = try parseRegister(line[1]);
        vals = @as(u8, try parseRegister(line[2])) << 4;
    } else if (std.mem.eql(u8, op.str(), "store")) {
        opcode = 0b0010;
        dest = try parseRegister(line[1]);
        vals = @as(u8, try parseRegister(line[2])) << 4;
    } else if (std.mem.eql(u8, op.str(), "add")) {
        opcode = 0b0011;
        dest = try parseRegister(line[1]);
        vals = try dualVal(line[2], line[3]);
    } else if (std.mem.eql(u8, op.str(), "sub")) {
        opcode = 0b0100;
        dest = try parseRegister(line[1]);
        vals = try dualVal(line[2], line[3]);
    } else if (std.mem.eql(u8, op.str(), "and")) {
        opcode = 0b0101;
        dest = try parseRegister(line[1]);
        vals = try dualVal(line[2], line[3]);
    } else if (std.mem.eql(u8, op.str(), "or")) {
        opcode = 0b0110;
        dest = try parseRegister(line[1]);
        vals = try dualVal(line[2], line[3]);
    } else if (std.mem.eql(u8, op.str(), "not")) {
        opcode = 0b0111;
        dest = try parseRegister(line[1]);
        vals = try dualVal(line[2], line[3]);
    } else if (std.mem.eql(u8, op.str(), "jump")) {
        opcode = 0b1000;
        vals = try indexOfLabel(line, labels) orelse return error.InvalidLabel;
    } else if (std.mem.eql(u8, op.str(), "jumpz")) {
        opcode = 0b1001;
        vals = try indexOfLabel(line, labels) orelse return error.InvalidLabel;
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

    const op16 = @as(u16, opcode) << 12;
    const dest16 = @as(u16, dest) << 8;
    const vals16 = @as(u16, vals);
    const res = op16 | dest16 | vals16;
    std.debug.print("bytecode: {s}\n", .{try utils.zeroPad(u16, res)});
    return res;
}

fn dualVal(w1: String, w2: String) !u8 {
    const val1 = try parseRegister(w1);
    const val2 = try parseRegister(w2);
    const res: u8 = (@as(u8, val1) << 4) | val2;
    return res;
}

fn indexOfLabel(line: [4]String, labels: *std.StringHashMap(usize)) !?u8 {
    const label = line[1];
    std.debug.print("label: {s} -> {?}\n", .{ label.str(), labels.get(label.str()) });
    if (labels.get(label.str())) |index| {
        if (index > 0b1111_1111) {
            return error.InvalidLabel;
        }
        return @as(u8, @intCast(index));
    } else {
        return null;
    }
}

pub fn parseRegister(reg: String) !u4 {
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
        res = 0b1000 | res;
    }
    return res;
}
