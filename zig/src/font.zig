const malloc = @import("malloc.zig").c_allocator;
const c = @import("imports.zig").c;
const std = @import("std");

pub const height: usize = 30;
pub const width: usize = 80;
var frame: [height][width:0]u8 = undefined;

pub var cursor: Cursor = .{ .x = 0, .y = 0 };

pub const Cursor = struct {
    x: usize,
    y: usize,

    pub fn left(self: *Cursor) void {
        if (self.x == 0) {
            self.x = width - 1;
        } else self.x -= 1;
    }

    pub fn up(self: *Cursor) void {
        if (self.y == 0) {
            self.y = height - 1;
        } else self.y -= 1;
    }

    pub fn right(self: *Cursor) void {
        if (self.x == width - 1) {
            self.x = 0;
        } else self.x += 1;
    }

    pub fn down(self: *Cursor) void {
        if (self.y == height - 1) {
            self.y = 0;
        } else self.y += 1;
    }

    pub fn next(self: *Cursor) void {
        if (self.x == width - 1) {
            self.x = 0;
            self.down();
        } else self.x += 1;
    }
};

pub fn draw_str(str: []u8) void {
    for (str) |x| {
        if (x == '\n') return;

        frame[cursor.y][cursor.x] = x;
        cursor.next();
    }
}

//pub usingnamespace @import("font_decl.zig");
pub fn init_frame() void {
    for (0..width) |i| {
        for (0..height) |j| {
            frame[j][i] = ' ';
        }
    }

    const default = @import("font_decl.zig");

    var x: usize = 0;
    draw_char(0, 0, default.F);
    x += char_info(default.F).x;

    draw_char(x, 0, default.O);
    x += char_info(default.O).x;

    draw_char(x, 0, default.O);
    x += char_info(default.O).x;
}

pub const Info = struct {
    x: usize,
    y: usize,
};

pub fn fill(char: u8) void {
    for (0..width) |i| {
        for (0..height) |j| {
            frame[j][i] = char;
        }
    }
}

pub fn clear() void {
    fill(' ');
}

pub fn char_info(str: []const u8) Info {
    var info = Info{ .x = 0, .y = 0 };
    var x: usize = 0;
    var y: usize = 1;

    for (str) |char| {
        if (char == '\n') {
            y += 1;
            x = 0;
            continue;
        }

        info.x = @max(x, info.x);
        x += 1;
    }

    info.y = y;

    return info;
}

pub fn draw_char(x0: usize, y0: usize, str: []const u8) void {
    var x = x0;
    var y = y0;

    for (str) |char| {
        if (char == '\n') {
            x = x0;
            y += 1;
            continue;
        }

        frame[y][x] = char;
        x += 1;
    }
}

pub fn write_frame(fd: c_int, use_cursor: bool) void {
    // Optimize such that we don't print useless spaces
    const buf: []u8 = malloc.alloc(u8, width + 1) catch @panic("out of memory");
    defer malloc.free(buf);

    for (0..height) |j| {
        buf[width] = 0;
        var found: bool = false;
        for (0..width) |i| {
            var val = frame[j][width - 1 - i];

            if (cursor.y == j and cursor.x == width - 1 - i and use_cursor)
                val = '#';

            found = found or val != ' ';

            buf[width - 1 - i] = if (found) val else 0;
        }

        c.fprintf(fd, "%s\n", &buf[0]);
    }
}

pub fn show_frame() void {
    write_frame(1, true);
}
