const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");

const String = @import("string").String;

pub fn parseLine(line: [4]String, labels: *std.StringHashMap(usize)) !u16 {
    var opcode: u4 = 0b0000;
    var dest: u4 = 0b0000;
    var vals: u8 = 0b0000_0000;
    const op = line[0];

    if (std.mem.eql(u8, op.str(), "loadi")) {
        opcode = 0b0000;
        dest = try parseRegister(line[1]);
        vals = try parseInt(line[2]);
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
    // std.debug.print("opcode: {d}\ndest: {d}\nvals: {d}\n", .{ opcode, dest, vals });
    return 0;
}

fn dualVal(w1: String, w2: String) !u8 {
    const val1 = try parseRegister(w1);
    const val2 = try parseRegister(w2);
    const res: u8 = (@as(u8, val1) << 4) | val2;
    return res;
}

fn parseInt(word: String) !u8 {
    var res: u8 = 0;
    var i: usize = 0;
    while (i < word.len()) : (i += 1) {
        const c = word.str()[i];
        if (c >= '0' and c <= '9') {
            res = res * 10 + (c - '0');
        } else {
            return error.InvalidInt;
        }
    }
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
        res = 0b1000 + res;
    }
    return res;
}
