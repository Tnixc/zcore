const std = @import("std");

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
    const cpu = Cpu{
        .PC = 0x0,
        .IR = 0x0,
        .Flags = 0x0,
        .Registers = [_]u16{0} ** 8,
        .Memory = [_]u16{0} ** 256,
    };
    std.debug.print("CPU!\n{any}\n", .{cpu});
    const sample = Instruction{
        .op = Op.load,
        .dest = 0,
        .src1 = 0,
        .src2 = 0,
    };
    std.debug.print("Sample instruction: {any}\n", .{sample});
}
