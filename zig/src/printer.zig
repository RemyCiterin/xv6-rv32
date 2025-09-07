const c = @import("imports.zig").c;
const std = @import("std");

fn writeFn(_: void, bytes: []const u8) error{}!usize {
    if (bytes.len == 0) return 0;
    const len = c.write(1, bytes.ptr, @intCast(bytes.len));
    return @intCast(len);
}

pub const Writer = std.io.Writer(void, error{}, writeFn);
pub const writer: Writer = .{ .context = {} };
