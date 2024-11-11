const std = @import("std");
const hfluint8 = @import("hfluint8.zig");

const max_memory = std.math.maxInt(u8) + 1;

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        stderr.print("Usage: {s} <program> [iterations [output]]\n", .{
            args[0],
        }) catch {}; // we want to return the relevant error
        return error.NoProgramSupplied;
    } else if (args.len > 4) {
        stderr.print("Usage: {s} <program> [iterations [output]]\n", .{
            args[0],
        }) catch {}; // we want to return the relevant error
        return error.TooManyArgs;
    }

    var program = try std.fs.cwd().openFile(args[1], .{});
    defer program.close();
    const program_reader = program.reader();

    const program_size = (try program.metadata()).size();

    if (program_size > max_memory) {
        stderr.print("Program must be at most {d} bytes\n", .{
            max_memory,
        }) catch {}; // we want to return the relevant error
        return error.ProgramTooLarge;
    }

    var memory: [max_memory]f16 = .{0} ** max_memory;

    for (0..program_size) |i| {
        memory[i] = @floatFromInt(try program_reader.readByte());
    }

    var iterations: ?usize = null;

    if (args.len >= 3) {
        iterations = try std.fmt.parseInt(usize, args[2], 0);
    }

    var output: ?[]u8 = null;
    if (args.len == 4) {
        output = args[3];
    }

    var program_counter: f16 = 0;
    while ((iterations orelse 1) > 0) : ({
        if (iterations) |_| {
            iterations.? -= 1;
        }
    }) {
        program_counter = subleq(&memory, program_counter);
    }

    try outputMemory(
        &memory,
        output orelse return,
    );
}

fn subleq(memory: []f16, program_counter: f16) f16 { // void {
    const a = memory[@intFromFloat(program_counter)];
    const b = memory[@intFromFloat(hfluint8.addMod256(program_counter, 1.0))];
    const c = memory[@intFromFloat(hfluint8.addMod256(program_counter, 2.0))];

    const sub = hfluint8.subMod256(
        memory[@as(usize, @intFromFloat(b))],
        memory[@as(usize, @intFromFloat(a))],
    );

    memory[@intFromFloat(b)] = sub;

    const leq = hfluint8.booleanOr(hfluint8.isSigned(sub), hfluint8.isZero(sub));
    return hfluint8.addMod256(
        hfluint8.ifCond(
            hfluint8.booleanNot(leq),
            hfluint8.addMod256(program_counter, 3),
        ),
        hfluint8.ifCond(leq, c),
    );
}

fn outputMemory(memory: *[max_memory]f16, filename: []u8) !void {
    const outfile: std.fs.File = try std.fs.cwd().createFile(
        filename,
        .{},
    );

    var casted_memory: [max_memory]u8 = [_]u8{undefined} ** max_memory;

    for (memory, 0..) |item, idx| {
        casted_memory[idx] = @intFromFloat(item);
    }

    try outfile.writeAll(&casted_memory);
}
