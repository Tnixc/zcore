const std = @import("std");
const main = @import("main.zig");
const utils = @import("util.zig");

const String = @import("string").String;

const parseOpcodeResult = struct {
    opcode: u4,
    dest: u4,
};

pub fn parseOpcode(line: [4]String) !parseOpcodeResult {
    var opcode: u4 = 0b0000;
    var dest: u4 = 0b0000;
    const op = line[0];

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
    const res = parseOpcodeResult{ .opcode = opcode, .dest = dest };
    return res;
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
