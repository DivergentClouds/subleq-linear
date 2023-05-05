// Acts on Half-Precision IEEE-754 floats as integers
// Uses only linear ops (addition and scaling by a constant)
// Always in the range [0, 256) when outside of a function
// Can go in the range of [-2048, 2048) without precision loss
// as per Murphy 2023 footnote 17
//
// Sources:
// - Most information comes from:
//   - http://tom7.org/grad/murphy2023grad.pdf (Murphy 2023)
// - Magic number constants + some shifting algorithms that weren't in the paper
//  (along with some knowledge from comments) come from:
//   - https://sourceforge.net/p/tom7misc/svn/HEAD/tree/trunk/grad/hfluint8.h
//   - https://sourceforge.net/p/tom7misc/svn/HEAD/tree/trunk/grad/hfluint8.cc

/// goes up to 256 for potential multi-hfluint8 numbers
pub const powers_of_2: [9]f16 = init: {
    var initial_value: [9]f16 = undefined;

    for (&initial_value, 0..) |*item, exponent| {
        item.* = @intToFloat(f16, 1 << exponent);
        // item.* = @bitCast(
        //     f16,
        //     0x3c00 // all but the highest exponent bit in f16, 1.0
        //     + 0x400 // lowest exponent bit in f16
        //     * @as(u16, exponent),
        // );
    }
    break :init initial_value;
};

/// assumes `a` is in the range [0, 256)
/// return value is in the range [0, 128)
pub fn rightShift1(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x37fa)); // 0.4985...

    const offset = @bitCast(f16, @as(u16, 0x66cd)); // 1741.0

    return a * scale + offset - offset;
}

/// assumes `a` is in the range [0, 256)
/// return value is the range [0, 1]
pub fn rightShift2(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x3400)); // 1/4

    // magic numbers taken from Murphy 2023
    const offset1 = @bitCast(f16, @as(u16, 0xb54e)); // -0.331...
    const offset2 = @bitCast(f16, @as(u16, 0x6417)); // 1047.0

    return a * scale + offset1 + offset2 - offset2;
}

/// assumes `a` is in the range [0, 256)
/// return value is the range [0, 1]
pub fn rightShift3(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x3000)); // 1/8

    // magic numbers taken from Murphy 2023
    const offset1 = @bitCast(f16, @as(u16, 0xb642)); // -0.391...
    const offset2 = @bitCast(f16, @as(u16, 0x67bc)); // 1980

    return a * scale + offset1 + offset2 - offset2;
}

/// assumes `a` in the range [0, 256)
/// return value is the range [0, 1]
pub fn rightShift4(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x2c00)); // 1/16

    // magic numbers taken from Murphy 2023
    const offset1 = @bitCast(f16, @as(u16, 0x37b5)); // 0.481...
    const offset2 = @bitCast(f16, @as(u16, 0x6630)); // 1584.0

    return (a * scale - offset1) + offset2 - offset2;
}

/// assumes `a` is in the range [0, 256)
/// return value is in the range [0, 1]
pub fn rightShift7(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x1c03)); // 0.0039...

    const offset = @bitCast(f16, @as(u16, 0x66c8)); // 1736.0

    return a * scale + offset - offset;
}

/// assumes `a` is in the range [0, 512)
/// return value is the range [0, 1]
pub fn rightShift8(a: f16) f16 {
    const scale = @bitCast(f16, @as(u16, 0x1c00)); // 1/256

    // magic numbers taken from Murphy 2023
    const offset1 = @bitCast(f16, @as(u16, 0xb7f6)); // -0.497...
    const offset2 = @bitCast(f16, @as(u16, 0x66b0)); // 1712.0

    return a * scale + offset1 + offset2 - offset2;
}

/// assumes `a` is in the range [0, 128)
/// return value is in the range [0, 256)
pub fn leftShift1NoOverflow(a: f16) f16 {
    return a * powers_of_2[1];
}

/// assumes `a` is in the range [0, 256)
/// return value is in the range [0, 256)
pub fn leftShift1(a: f16) f16 {
    return addMod256(a, a);
}

/// `a` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn leftShift2(a: f16) f16 {
    const scale = @as(f16, 256); // 256.0

    const shifted = a * powers_of_2[2];
    const overflow = rightShift8(shifted);

    // parentheses for clarification, they do not change the result
    return shifted - (overflow * scale);
}

/// `a` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn leftShift3(a: f16) f16 {
    const scale = @as(f16, 256); // 256.0

    // precision is lost above 2047 so you can't go further than this
    // without adjusting for overflow between shifts
    const shifted = a * powers_of_2[3];
    const overflow = rightShift8(shifted);

    // parentheses for clarification, they do not change the result
    return shifted - (overflow * scale);
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn addMod256(a: f16, b: f16) f16 {
    const scale = @as(f16, 256); // 256.0

    const sum = a + b;
    const overflow = rightShift8(sum);

    // parentheses for clarification, they do not change the result
    return sum - (overflow * scale);
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn subMod256(a: f16, b: f16) f16 {
    return addMod256(
        a,
        addMod256(bitwiseNot(b), 1),
    );
}

/// `a` and `b` must be in the range [0, 1]
/// return value is in the range [0, 1]
pub fn booleanAnd(a: f16, b: f16) f16 {
    return rightShift1(a + b);
}

/// `a` and `b` must be in the range [0, 1]
/// return value is in the range [0, 1]
pub fn booleanOr(a: f16, b: f16) f16 {
    const common = booleanAnd(a, b);
    return (a - common) + b;
}

/// `a` and `b` must be in the range [0, 1]
/// return value is in the range [0, 1]
pub fn booleanXor(a: f16, b: f16) f16 {
    const common = booleanAnd(a, b);
    return (a - common) + (b - common);
}

/// `a` must be in the range [0, 1]
/// return value is in the range [0, 1]
pub fn booleanNot(a: f16) f16 {
    return @as(f16, 1) - a;
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn bitwiseAnd(a: f16, b: f16) f16 {
    var result = @as(f16, 0); // 0.0
    var a_mutable = a;
    var b_mutable = b;

    // `inline` forces the loop to be unrolled
    // (it would probably be unrolled either way, but better safe than sorry)
    inline for (0..8) |bit_index| {
        // low order bit via `a - ((a >> 1) << 1)
        const a_shifted = rightShift1(a_mutable);
        const b_shifted = rightShift1(b_mutable);
        const a_bit = a_mutable - leftShift1NoOverflow(a_shifted);
        const b_bit = b_mutable - leftShift1NoOverflow(b_shifted);

        const scale = powers_of_2[bit_index];

        const and_bit = booleanAnd(a_bit, b_bit); // (a + b) >> 1 == a & b
        result += scale * and_bit;

        // shift down further
        a_mutable = a_shifted;
        b_mutable = b_shifted;
    }

    return result;
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn bitwiseOr(a: f16, b: f16) f16 {
    const common = bitwiseAnd(a, b);
    return (a - common) + b;
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn bitwiseXor(a: f16, b: f16) f16 {
    const common = bitwiseAnd(a, b);
    return (a - common) + (b - common);
}

/// `a` must be in the range [0, 256)
/// return value is in the range [0, 256)
pub fn bitwiseNot(a: f16) f16 {
    return @as(f16, 255) - a;
}

/// `a` must be in the range [0, 256)
/// return value is in the range [0, 1]
pub fn isZero(a: f16) f16 {
    return rightShift8(
        bitwiseNot(a) + @as(f16, 1),
    ); // 1 if (~a + 1) overflowed, else 0
}

/// `a` must be in the range [0, 256)
/// return value is in the range [0, 1]
pub fn isSigned(a: f16) f16 {
    return rightShift7(a);
}

/// `a` and `b` must be in the range [0, 256)
/// return value is in the range [0, 1]
pub fn isEqual(a: f16, b: f16) f16 {
    // the paper uses C++ operator overloading to do this
    return isZero(subMod256(a, b));
}

/// `condition` must be in the range [0, 1]
/// `a` must be in the range [0, 256)
/// return value is `a` if `condition` is 1, otherwise 0
pub fn ifCond(condition: f16, a: f16) f16 {
    // if you add and subtract all of these from a hfluint8 then
    // the lower 6 bits are cleared due to rounding
    const off = [8]f16{
        @bitCast(f16, @as(u16, 0x77f9)),
        @bitCast(f16, @as(u16, 0x7829)),
        @bitCast(f16, @as(u16, 0x77fb)),
        @bitCast(f16, @as(u16, 0x78e2)),
        @bitCast(f16, @as(u16, 0x77fd)),
        @bitCast(f16, @as(u16, 0x780b)),
        @bitCast(f16, @as(u16, 0x77ff)),
        @bitCast(f16, @as(u16, 0x7864)),
    };

    var mutable_a = a;

    // boolean not of `condition`
    const not_condition = booleanNot(condition);

    // 128 if condition is false
    const conditional_128 = @as(f16, 128) * not_condition;

    var conditional_off: [8]f16 = undefined;

    // `inline` to make sure loop is unrolled
    inline for (&conditional_off, 0..) |*item, i| {
        // This results in 0 or the item
        item.* = off[i] * not_condition;
    }

    // conditionally clear the bottom bits of mutable_a
    // `inline` to make sure loop is unrolled
    inline for (conditional_off) |item| {
        mutable_a = mutable_a + item - item;
    }

    // subtract from 128 if `condition` is false, otherwise flip sign
    mutable_a = conditional_128 - mutable_a;

    // conditionally clear the bottom bits again
    inline for (conditional_off) |item| {
        mutable_a = mutable_a + item - item;
    }

    // if `condition` is true then the sign was flipped, multiply by -1 to fix
    // Add 0 to prevent a -0 output
    return mutable_a * @as(f16, -1) + @as(f16, 0);
}
