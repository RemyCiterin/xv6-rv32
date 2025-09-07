const c = @import("imports.zig").c;
const std = @import("std");

const Allocator = std.mem.Allocator;
const Alignment = std.mem.Alignment;
const assert = std.debug.assert;
const mem = std.mem;

/// Copied from Zig std/heap, this file define a Zig allocator using `malloc` and `free` C
/// functions and follow Zig alignment contraints.
const CAllocator = struct {
    const vtable: Allocator.VTable = .{
        .alloc = alloc,
        .resize = resize,
        .remap = remap,
        .free = free,
    };

    fn getHeader(ptr: [*]u8) *[*]u8 {
        return @ptrCast(@alignCast(ptr - @sizeOf(usize)));
    }

    fn alignedAlloc(len: usize, alignment: Alignment) ?[*]u8 {
        const alignment_bytes = alignment.toByteUnits();
        // Thin wrapper around regular malloc, overallocate to account for
        // alignment padding and store the original malloc()'ed pointer before
        // the aligned address.
        const unaligned_ptr = @as([*]u8, @ptrCast(c.malloc(
            len + alignment_bytes - 1 + @sizeOf(usize),
        ) orelse return null));

        const unaligned_addr = @intFromPtr(unaligned_ptr);
        const aligned_addr =
            mem.alignForward(usize, unaligned_addr + @sizeOf(usize), alignment_bytes);
        const aligned_ptr =
            unaligned_ptr + (aligned_addr - unaligned_addr);
        getHeader(aligned_ptr).* = unaligned_ptr;

        return aligned_ptr;
    }

    fn alignedFree(ptr: [*]u8) void {
        const unaligned_ptr = getHeader(ptr).*;
        c.free(unaligned_ptr);
    }

    fn alloc(
        _: *anyopaque,
        len: usize,
        alignment: Alignment,
        return_address: usize,
    ) ?[*]u8 {
        _ = return_address;
        assert(len > 0);
        return alignedAlloc(len, alignment);
    }

    fn resize(
        _: *anyopaque,
        buf: []u8,
        alignment: Alignment,
        new_len: usize,
        return_address: usize,
    ) bool {
        _ = alignment;
        _ = return_address;
        if (new_len <= buf.len) {
            return true;
        }
        return false;
    }

    fn remap(
        context: *anyopaque,
        memory: []u8,
        alignment: Alignment,
        new_len: usize,
        return_address: usize,
    ) ?[*]u8 {
        // realloc would potentially return a new allocation that does not
        // respect the original alignment.
        return if (resize(context, memory, alignment, new_len, return_address)) memory.ptr else null;
    }

    fn free(
        _: *anyopaque,
        buf: []u8,
        alignment: Alignment,
        return_address: usize,
    ) void {
        _ = alignment;
        _ = return_address;
        alignedFree(buf.ptr);
    }
};

pub const c_allocator: Allocator = .{
    .ptr = undefined,
    .vtable = &CAllocator.vtable,
};
