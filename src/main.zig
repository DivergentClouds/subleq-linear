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
