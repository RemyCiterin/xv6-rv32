const std = @import("std");
const writer = @import("printer.zig").writer;
const c = @import("imports.zig").c;
const malloc = @import("malloc.zig").c_allocator;
const font = @import("font.zig");

pub export fn _start() linksection(".text._start") callconv(.C) void {
    main();
}

pub const std_options = std.Options{
    .log_level = .info,
    .logFn = log,
};

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const prefix =
        "[" ++ comptime level.asText() ++ ":" ++ @tagName(scope) ++ "] ";
    writer.print(prefix ++ format, args) catch unreachable;
    writer.print("\n", .{}) catch unreachable;
}

pub fn panic(
    message: []const u8,
    _: ?*std.builtin.StackTrace,
    _: ?usize,
) noreturn {
    std.log.err("Error: PANIC \"{s}\"\n\n", .{message});
    c.exit(1);
}

// Allocate a buffer with the content of a file
pub fn readAllFile(fd: c_int) ![]u8 {
    var list = std.ArrayList(u8).initCapacity(malloc, 0) catch unreachable;

    var index: usize = 0;

    const bsize: usize = 512;
    while (true) : (index += bsize) {
        list.appendNTimes(0, bsize) catch unreachable;
        const x = c.read(fd, list.items[index..].ptr, bsize);

        if (x < bsize) {
            return list.items;
        }
    }
}

pub export fn main() void {
    const logger = std.log.scoped(.main);

    const fd = c.open("font.txt", 0);
    const file = readAllFile(fd) catch unreachable;
    defer c.close(fd);
    _ = file;

    font.init_frame();
    font.show_frame();

    while (true) {
        var user_input: u8 = undefined;
        _ = c.read(0, &user_input, 1);

        switch (user_input) {
            'i' => {
                const line = malloc.alloc(u8, 1024) catch @panic("out of memory");
                defer malloc.free(line);
                _ = c.gets(line.ptr, 1024);

                font.draw_str(line);
            },
            's' => {
                const line = malloc.alloc(u8, 1024) catch @panic("out of memory");
                defer malloc.free(line);
                _ = c.gets(line.ptr, 1024);

                for (line) |*char| {
                    if (char.* == '\n') char.* = 0;
                }

                const save = c.open(line.ptr, c.O_RDWR | c.O_CREATE);
                defer _ = c.close(save);

                font.write_frame(save, false);
            },

            // left
            'h' => {
                font.cursor.left();
            },
            // down
            'j' => {
                font.cursor.down();
            },
            // up
            'k' => {
                font.cursor.up();
            },
            // right
            'l' => {
                font.cursor.right();
            },
            // To the begin of the line
            'I' => {
                font.cursor.x = 0;
            },
            // Zero
            'z' => {
                font.cursor = .{ .x = 0, .y = 0 };
            },

            'c' => {
                font.clear();
            },

            'q' => break,
            '\n' => continue,
            else => {
                logger.info("undefined command `{c}`", .{user_input});
                @panic("");
            },
        }

        c.printf("\n");
        font.show_frame();
    }

    const buffer: ?*anyopaque = c.malloc(42);
    c.free(buffer);
    c.exit(0);
}
