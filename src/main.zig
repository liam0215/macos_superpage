const std = @import("std");

const c = @cImport({
    @cInclude("sys/mman.h");
    @cInclude("mach/vm_statistics.h");
    @cInclude("mach/mach.h");
    @cInclude("mach/mach_vm.h");
});

const Error = error{
    MmapFailed,
    MunmapFailed,
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    // Request a 2 MB mapping; size must be a multiple of 2 MB.
    const size: usize = 2 * 1024 * 1024;

    // Set protection and mapping flags.
    // Note: VM_FLAGS_SUPERPAGE_SIZE_2MB is a Mach flag hint.
    const prot: c_int = c.PROT_READ;
    const flags: c_int = c.MAP_ANON | c.MAP_PRIVATE;
    const fd: c_int = c.VM_FLAGS_SUPERPAGE_SIZE_2MB;
    const offset: c_int = 0;

    // Call mmap. (Using the C function directly via Zig’s @cImport)
    const addr = c.mmap(null, size, prot, flags, fd, offset);
    // const addr: [*c]c.mach_vm_address_t = 0;
    // const kr = c.mach_vm_allocate(c.mach_task_self(), addr, size, c.VM_FLAGS_ANYWHERE | c.VM_FLAGS_SUPERPAGE_SIZE_2MB);

    // const kr = c.mach_vm_allocate(c.mach_task_self(), addr, size, c.VM_FLAGS_ANYWHERE);
    // if (kr != 0) {
    //     try stdout.print("Mapping failed, error: {?}\n", .{kr});
    //     return Error.MmapFailed;
    // }
    // if (addr == 0) {
    //     try stdout.print("Mapping failed, address is null\n", .{});
    //     return Error.MmapFailed;
    // }
    if (addr == c.MAP_FAILED) {
        try stdout.print("Mapping failed, address is null\n", .{});
        return Error.MmapFailed;
    }
    // try stdout.print("Mapping succeeded at address: {?p}\n", .{addr});
    try stdout.print("Mapping succeeded at address: {?p}\n", .{addr});

    // (Optional) Do something with the memory.
    // For demonstration, we zero it out.
    const mem: [*]u8 = @ptrCast(addr);
    @memset(mem[0..size], 0);

    // Clean up: unmap the memory.
    const ret = c.munmap(addr, size);
    if (ret != 0) {
        return Error.MunmapFailed;
    }
    try stdout.print("Mapping unmapped successfully.\n", .{});
}
