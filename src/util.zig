const std = @import("std");

pub fn StrToU8(str: []const u8) []const u8 {
    return str;
}

pub fn zeroPad(comptime T: type, value: T) ![]const u8 {
    const bits = @typeInfo(T).int.bits;
    var arr: [bits]u8 = undefined;
    var i: usize = bits;
    while (i > 0) : (i -= 1) {
        arr[i - 1] = if (value & (@as(T, 1) << @intCast(bits - i)) != 0) '1' else '0';
    }
    const return_arr = try std.fmt.allocPrint(std.heap.page_allocator, "{s}", .{arr});
    return return_arr;
}

pub const whitelist = [_]u8{ ' ', '\t', '\n', '\r' };
