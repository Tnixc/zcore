const std = @import("std");
const read = @import("read.zig");
const parse = @import("parse.zig");
const string = @import("string");
const utils = @import("util.zig");

pub const Op = enum { load, store, ALUadd, ALUsub, ALUand, ALUor, ALUnot, jump, jumpz, halt, IOin, IOout };

pub const Instruction = struct {
    op: Op,
    dest: u4,
    src1: u4,
    src2: u4,
};

pub const Cpu = struct {
    PC: u16,
    IR: u16,
    Flags: u8,
    Registers: [8]u16,
    WorkingMemory: [256]u16,
    ProgramMemory: [256]u16,
};

pub fn main() !void {
    const instructions = try read.readFileToMachineCode("bar.asm");
    for (instructions) |instr| {
        std.debug.print("instr: {s}\n", .{try utils.zeroPad(u16, instr)});
    }
    // std.debug.print("a: {b}\n", .{a});
    // const cpu = Cpu{
    //     .PC = 0,
    //     .IR = 0,
    //     .Flags = 0b0000_0000,
    //     .Registers = [_]u16{0} ** 8,
    //     .WorkingMemory = [_]u16{0} ** 256,
    //     .ProgramMemory = [_]u16{0} ** 256,
    // };
    // std.debug.print("CPU!\n{any}\n", .{cpu});
}
