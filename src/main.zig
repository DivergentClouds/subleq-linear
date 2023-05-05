const std = @import("std");
const half = @import("hfluint8.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        const stderr = std.io.getStdErr();
        stderr.writer().print("Usage: {s} <program> [iterations [output]]\n", .{args[0]}) catch {}; // we want to return the relevant error
        return error.NoProgramSupplied;
    } else if (args.len > 4) {
        const stderr = std.io.getStdErr();
        stderr.writer().print("Usage: {s} <program> [iterations [output]]\n", .{args[0]}) catch {}; // we want to return the relevant error
        return error.TooManyArgs;
    }

    var program = try std.fs.cwd().openFile(args[1], .{});
    const program_reader = program.reader();
    defer program.close();

    const max_memory = std.math.maxInt(u8) + 1;
    const program_size = (try program.metadata()).size();

    if (program_size > max_memory) {
        const stderr = std.io.getStdErr();
        stderr.writer().print("Program must be at most {d} bytes\n", .{max_memory}) catch {}; // we want to return the relevant error
        return error.ProgramTooLarge;
    }

    var memory: [max_memory]f16 = undefined;

    for (0..program_size) |i| {
        memory[i] = @intToFloat(f16, try program_reader.readByte());
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
    while (iterations orelse 1 > 0) : ({
        if (iterations) |_| {
            iterations.? -= 1;
        }
    }) {
        program_counter = subleq(&memory, program_counter);
    }

    try outputMemory(&memory, output);
}

fn subleq(memory: []f16, program_counter: f16) f16 { // void {
    // while (true) {
    const a = memory[@floatToInt(usize, program_counter)];
    const b = memory[@floatToInt(usize, half.addMod256(program_counter, 1.0))];
    const c = memory[@floatToInt(usize, half.addMod256(program_counter, 2.0))];

    const sub = half.subMod256(memory[@floatToInt(usize, b)], memory[@floatToInt(usize, a)]);

    memory[@floatToInt(usize, b)] = sub;

    const leq = half.booleanOr(half.isSigned(sub), half.isZero(sub));
    // program_counter =
    return half.ifCond(
        half.booleanNot(leq),
        half.addMod256(program_counter, 3),
    ) + half.ifCond(leq, c);
    // }

    // return program_counter;
}

fn outputMemory(memory: []f16, filename: ?[]u8) !void {
    const outfile: std.fs.File = try std.fs.cwd().createFile(filename orelse return, .{});
    const outfile_writer = outfile.writer();

    for (memory) |item| {
        try outfile_writer.writeByte(@floatToInt(u8, item));
    }
}

// uses non-linear operations, yuck
// for compairison only
fn subleqBranched(memory: []u8, initial_pc: u8) u8 { // void {
    var program_counter: u8 = initial_pc;

    // while (true) {
    const a = memory[program_counter];
    const b = memory[program_counter +% 1];
    const c = memory[program_counter +% 2];

    const sub = memory[b] -% memory[a];

    memory[b] = sub;

    const leq = @bitCast(i8, sub) <= 0;
    if (leq) {
        program_counter = c;
    } else {
        program_counter +%= 3;
    }
    // }

    return program_counter;
}

test "subleq linear" {
    var memory = [_]f16{127.0} ** 256;
    var pc: f16 = 0.0;

    for (0..(@as(usize, 1) << 22)) |_| {
        pc = subleq(&memory, pc);
    }
}

test "subleq branched" {
    var memory = [_]u8{127} ** 256;
    var pc: u8 = 0;

    for (0..(@as(usize, 1) << 22)) |_| {
        pc = subleqBranched(&memory, pc);
    }
}
