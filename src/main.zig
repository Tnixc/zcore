const std = @import("std");
const read = @import("read.zig");
const parse = @import("parse.zig");
const string = @import("string");
const utils = @import("util.zig");
const cpu = @import("cpu/cpu.zig");
const registers = @import("cpu/registers.zig");

pub fn main() !void {
    const instructions = try read.readFileToMachineCode("bar.asm");
    // for (instructions) |instr| {
    //     std.debug.print("instr: {s}\n", .{try utils.zeroPad(u16, instr)});
    // }
    var z = cpu.Cpu{
        .PC = 0,
        .IR = 0,
        .Flags = 0b0000_0000,
        .Registers = [_]u8{0} ** 8,
        .WorkingMemory = [_]u16{0} ** 256,
        .Program = instructions,
    };
    z.Flags |= 0b1000_0000;
    std.debug.print("CPU!\n{any}\n", .{z});
}
