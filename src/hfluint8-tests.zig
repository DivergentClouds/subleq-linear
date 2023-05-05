const half = @import("hfluint8.zig");
const std = @import("std");
const testing = std.testing;

test "rightShift1" {
    for (0..256) |a| {
        try testing.expect(half.rightShift1(
            @intToFloat(f16, a),
        ) == @intToFloat(
            f16,
            a >> 1,
        ));
    }
}

test "rightShift2" {
    for (0..256) |a| {
        try testing.expect(half.rightShift2(
            @intToFloat(f16, a),
        ) == @intToFloat(
            f16,
            a >> 2,
        ));
    }
}

test "rightShift3" {
    for (0..256) |a| {
        try testing.expect(half.rightShift3(
            @intToFloat(f16, a),
        ) == @intToFloat(
            f16,
            a >> 3,
        ));
    }
}

test "rightShift4" {
    for (0..256) |a| {
        try testing.expect(half.rightShift4(
            @intToFloat(f16, a),
        ) == @intToFloat(
            f16,
            a >> 4,
        ));
    }
}

test "rightShift7" {
    for (0..256) |a| {
        try testing.expect(half.rightShift7(
            @intToFloat(f16, a),
        ) == @intToFloat(
            f16,
            a >> 7,
        ));
    }
}

test "rightShift8" {
    for (0..512) |a| {
        try testing.expect(half.rightShift8(
            @intToFloat(f16, a),
        ) == @intToFloat(f16, a >> 8));
    }
}

test "leftShift1NoOverflow" {
    for (0..128) |a| {
        try testing.expect(
            half.leftShift1NoOverflow(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, a << 1),
        );
    }
}
test "leftShift1" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift1(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, (a - @divFloor(a, 128) * 128) << 1),
        );
    }
}

test "leftShift2" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift2(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, (a - @divFloor(a, 64) * 64) << 2),
        );
    }
}

test "leftShift3" {
    for (0..256) |a| {
        try testing.expect(
            half.leftShift3(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, (a - @divFloor(a, 32) * 32) << 3),
        );
    }
}

test "addMod256" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.addMod256(
                    @intToFloat(f16, a),
                    @intToFloat(f16, b),
                ) == @intToFloat(f16, @truncate(u8, a) +% @truncate(u8, b)),
            );
        }
    }
}

test "booleanAnd" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanAnd(
                @intToFloat(f16, a),
                @intToFloat(f16, b),
            ) == @intToFloat(f16, a & b));
        }
    }
}

test "booleanOr" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanOr(
                @intToFloat(f16, a),
                @intToFloat(f16, b),
            ) == @intToFloat(f16, a | b));
        }
    }
}

test "booleanXor" {
    for (0..2) |a| {
        for (0..2) |b| {
            try testing.expect(half.booleanXor(
                @intToFloat(f16, a),
                @intToFloat(f16, b),
            ) == @intToFloat(f16, a ^ b));
        }
    }
}

test "booleanNot" {
    for (0..2) |a| {
        try testing.expect(half.booleanNot(
            @intToFloat(f16, a),
        ) == @intToFloat(f16, @boolToInt(a == 0)));
    }
}

test "bitwiseAnd" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseAnd(
                    @intToFloat(f16, a),
                    @intToFloat(f16, b),
                ) == @intToFloat(f16, a & b),
            );
        }
    }
}

test "bitwiseOr" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseOr(
                    @intToFloat(f16, a),
                    @intToFloat(f16, b),
                ) == @intToFloat(f16, a | b),
            );
        }
    }
}

test "bitwiseXor" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.bitwiseXor(
                    @intToFloat(f16, a),
                    @intToFloat(f16, b),
                ) == @intToFloat(f16, a ^ b),
            );
        }
    }
}

test "bitwiseNot" {
    for (0..256) |a| {
        try testing.expect(
            half.bitwiseNot(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, ~@truncate(u8, a)),
        );
    }
}

test "isZero" {
    for (0..256) |a| {
        try testing.expect(
            half.isZero(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, @boolToInt(a == 0)),
        );
    }
}

test "isSigned" {
    for (0..256) |a| {
        try testing.expect(
            half.isSigned(
                @intToFloat(f16, a),
            ) == @intToFloat(f16, @boolToInt(a > 127)),
        );
    }
}

test "isEqual" {
    for (0..256) |a| {
        for (0..256) |b| {
            try testing.expect(
                half.isEqual(
                    @intToFloat(f16, a),
                    @intToFloat(f16, b),
                ) == @intToFloat(f16, @boolToInt(a == b)),
            );
        }
    }
}

test "ifCond false" {
    for (0..256) |a| {
        try testing.expect(
            half.ifCond(
                @as(f16, 0),
                @intToFloat(f16, a),
            ) == @as(f16, 0),
        );
    }
}

test "ifCond true" {
    for (0..256) |a| {
        try testing.expect(
            half.ifCond(
                @as(f16, 1),
                @intToFloat(f16, a),
            ) == @intToFloat(f16, a),
        );
    }
}
