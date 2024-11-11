const hfluint8 = @import("hfluint8.zig");
const std = @import("std");
const testing = std.testing;

test "rightShift1" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.rightShift1(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 1),
            ),
        );
    }
}

test "rightShift2" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.rightShift2(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 2),
            ),
        );
    }
}

test "rightShift3" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.rightShift3(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 3),
            ),
        );
    }
}

test "rightShift4" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.rightShift4(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 4),
            ),
        );
    }
}

test "rightShift7" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.rightShift7(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 7),
            ),
        );
    }
}

test "rightShift8" {
    for (0..512) |a| {
        try testing.expectEqual(
            hfluint8.rightShift8(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a >> 8),
            ),
        );
    }
}

test "leftShift1NoOverflow" {
    for (0..128) |a| {
        try testing.expectEqual(
            hfluint8.leftShift1NoOverflow(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a << 1),
            ),
        );
    }
}
test "leftShift1" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.leftShift1(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    a % 128 << 1,
                ),
            ),
        );
    }
}

test "leftShift2" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.leftShift2(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    a % 64 << 2,
                ),
            ),
        );
    }
}

test "leftShift3" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.leftShift3(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    a % 32 << 3,
                ),
            ),
        );
    }
}

test "addMod256" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.addMod256(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(
                        @as(u8, @intCast(a)) +% @as(u8, @intCast(b)),
                    ),
                ),
            );
        }
    }
}

test "subMod256" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.subMod256(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(
                        @as(u8, @intCast(a)) -% @as(u8, @intCast(b)),
                    ),
                ),
            );
        }
    }
}

test "booleanAnd" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expectEqual(
                hfluint8.booleanAnd(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a & b),
                ),
            );
        }
    }
}

test "booleanOr" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expectEqual(
                hfluint8.booleanOr(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a | b),
                ),
            );
        }
    }
}

test "booleanXor" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expectEqual(
                hfluint8.booleanXor(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a ^ b),
                ),
            );
        }
    }
}

test "booleanNot" {
    for (0..2) |a| {
        try testing.expectEqual(
            hfluint8.booleanNot(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(1 - a),
            ),
        );
    }
}

test "bitwiseAnd" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.bitwiseAnd(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a & b),
                ),
            );
        }
    }
}

test "bitwiseOr" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.bitwiseOr(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a | b),
                ),
            );
        }
    }
}

test "bitwiseXor" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.bitwiseXor(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(a ^ b),
                ),
            );
        }
    }
}

test "bitwiseNot" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.bitwiseNot(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    ~@as(u8, @intCast(a)),
                ),
            ),
        );
    }
}

test "isZero" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.isZero(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    @intFromBool(a == 0),
                ),
            ),
        );
    }
}

test "isSigned" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.isSigned(
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(
                    @intFromBool(a > 127),
                ),
            ),
        );
    }
}

test "isEqual" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expectEqual(
                hfluint8.isEqual(
                    @floatFromInt(a),
                    @floatFromInt(b),
                ),
                @as(
                    f16,
                    @floatFromInt(
                        @intFromBool(a == b),
                    ),
                ),
            );
        }
    }
}

test "ifCond false" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.ifCond(
                0,
                @floatFromInt(a),
            ),
            0.0,
        );
    }
}

test "ifCond true" {
    for (0..256) |a| {
        try testing.expectEqual(
            hfluint8.ifCond(
                1,
                @floatFromInt(a),
            ),
            @as(
                f16,
                @floatFromInt(a),
            ),
        );
    }
}
