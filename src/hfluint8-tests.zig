const half = @import("hfluint8.zig");
const std = @import("std");
const testing = std.testing;

test "rightShift1" {
    for (0..256) |a| {
        try testing.expect(half.rightShift1(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 1)));
    }
}

test "rightShift2" {
    for (0..256) |a| {
        try testing.expect(half.rightShift2(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 2)));
    }
}

test "rightShift3" {
    for (0..256) |a| {
        try testing.expect(half.rightShift3(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 3)));
    }
}

test "rightShift4" {
    for (0..256) |a| {
        try testing.expect(half.rightShift4(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 4)));
    }
}

test "rightShift7" {
    for (0..256) |a| {
        try testing.expect(half.rightShift7(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 7)));
    }
}

test "rightShift8" {
    for (0..512) |a| {
        try testing.expect(half.rightShift8(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(a >> 8)));
    }
}

test "leftShift1NoOverflow" {
    for (0..128) |a| {
        try testing.expect(
            half.leftShift1NoOverflow(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt(a << 1)),
        );
    }
}
test "leftShift1" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift1(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt((a - @divFloor(a, 128) * 128) << 1)),
        );
    }
}

test "leftShift2" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift2(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt((a - @divFloor(a, 64) * 64) << 2)),
        );
    }
}

test "leftShift3" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift3(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt((a - @divFloor(a, 32) * 32) << 3)),
        );
    }
}

test "addMod256" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.addMod256(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ) == @as(
                    f16,
                    @floatFromInt(@as(u8, @truncate(a)) +% @as(u8, @truncate(b))),
                ),
            );
        }
    }
}

test "booleanAnd" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanAnd(
                @floatFromInt(a),
                @floatFromInt(b),
            ) == @as(f16, @floatFromInt(a & b)));
        }
    }
}

test "booleanOr" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanOr(
                @floatFromInt(a),
                @floatFromInt(b),
            ) == @as(f16, @floatFromInt(a | b)));
        }
    }
}

test "booleanXor" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanXor(
                @floatFromInt(a),
                @floatFromInt(b),
            ) == @as(f16, @floatFromInt(a ^ b)));
        }
    }
}

test "booleanNot" {
    for (0..2) |a| {
        try testing.expect(half.booleanNot(
            @floatFromInt(a),
        ) == @as(f16, @floatFromInt(@intFromBool(a == 0))));
    }
}

test "bitwiseAnd" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseAnd(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ) == @as(f16, @floatFromInt(a & b)),
            );
        }
    }
}

test "bitwiseOr" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseOr(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ) == @as(f16, @floatFromInt(a | b)),
            );
        }
    }
}

test "bitwiseXor" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseXor(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ) == @as(f16, @floatFromInt(a ^ b)),
            );
        }
    }
}

test "bitwiseNot" {
    for (0..256) |a| {
        try testing.expect(
            half.bitwiseNot(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt(~@as(u8, @truncate(a)))),
        );
    }
}

test "isZero" {
    for (0..256) |a| {
        try testing.expect(
            half.isZero(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt(@intFromBool(a == 0))),
        );
    }
}

test "isSigned" {
    for (0..256) |a| {
        try testing.expect(
            half.isSigned(
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt(@intFromBool(a > 127))),
        );
    }
}

test "isEqual" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.isEqual(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ) == @as(f16, @floatFromInt(@intFromBool(a == b))),
            );
        }
    }
}

test "ifCond false" {
    for (0..256) |a| {
        try testing.expect(
            half.ifCond(
                0,
                @floatFromInt(a),
            ) == @as(f16, 0),
        );
    }
}

test "ifCond true" {
    for (0..256) |a| {
        try testing.expect(
            half.ifCond(
                1,
                @floatFromInt(a),
            ) == @as(f16, @floatFromInt(a)),
        );
    }
}
