pub const Op = enum { load, store, ALUadd, ALUsub, ALUand, ALUor, ALUnot, jump, jumpz, halt, IOin, IOout };

pub const Cpu = struct {
    PC: u16,
    IR: u16,
    Flags: u8,
    Registers: [8]u16,
    WorkingMemory: [256]u16,
    Program: []const u16,
};
