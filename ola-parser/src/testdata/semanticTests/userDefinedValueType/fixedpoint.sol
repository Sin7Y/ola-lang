// Represent a 18 decimal, 256 bit wide fixed point type using a user defined value type.
type UFixed256x18 is u256;

/// A minimal library to do fixed point operations on UFixed256x18.
library FixedMath {
    u256 constant multiplier = 10**18;
    /// Adds two UFixed256x18 numbers. Reverts on overflow, relying on checked arithmetic on
    /// u256.
    fn add(UFixed256x18 a, UFixed256x18 b) internal -> (UFixed256x18) {
        return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
    }
    /// Multiplies UFixed256x18 and u256. Reverts on overflow, relying on checked arithmetic on
    /// u256.
    fn mul(UFixed256x18 a, u256 b) internal -> (UFixed256x18) {
        return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
    }
    /// Take the floor of a UFixed256x18 number.
    /// @return the largest integer that does not exceed `a`.
    fn floor(UFixed256x18 a) internal -> (u256) {
        return UFixed256x18.unwrap(a) / multiplier;
    }
    /// Turns a u256 into a UFixed256x18 of the same value.
    /// Reverts if the integer is too large.
    fn toUFixed256x18(u256 a) internal pure -> (UFixed256x18) {
        return UFixed256x18.wrap(a * multiplier);
    }
}

contract TestFixedMath {
    fn add(UFixed256x18 a, UFixed256x18 b) external -> (UFixed256x18) {
        return FixedMath.add(a, b);
    }
    fn mul(UFixed256x18 a, u256 b) external -> (UFixed256x18) {
        return FixedMath.mul(a, b);
    }
    fn floor(UFixed256x18 a) external -> (u256) {
        return FixedMath.floor(a);
    }
    fn toUFixed256x18(u256 a) external -> (UFixed256x18) {
        return FixedMath.toUFixed256x18(a);
    }
}
// ====
// compileViaYul: also
// ----
// add(u256,u256): 0, 0 -> 0
// add(u256,u256): 25, 45 -> 0x46
// add(u256,u256): 115792089237316195423570985008687907853269984665640564039457584007913129639935, 10 -> FAILURE, hex"4e487b71", 0x11
// mul(u256,u256): 340282366920938463463374607431768211456, 45671926166590716193865151022383844364247891968 -> FAILURE, hex"4e487b71", 0x11
// mul(u256,u256): 340282366920938463463374607431768211456, 20 -> 6805647338418769269267492148635364229120
// floor(u256): 11579208923731619542357098500868790785326998665640564039457584007913129639930 -> 11579208923731619542357098500868790785326998665640564039457
// floor(u256): 115792089237316195423570985008687907853269984665640564039457584007913129639935 -> 115792089237316195423570985008687907853269984665640564039457
// toUFixed256x18(u256): 0 -> 0
// toUFixed256x18(u256): 5 -> 5000000000000000000
// toUFixed256x18(u256): 115792089237316195423570985008687907853269984665640564039457 -> 115792089237316195423570985008687907853269984665640564039457000000000000000000
// toUFixed256x18(u256): 115792089237316195423570985008687907853269984665640564039458 -> FAILURE, hex"4e487b71", 0x11
