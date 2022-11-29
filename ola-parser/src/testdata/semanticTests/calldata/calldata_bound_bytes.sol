pragma abicoder v2;

library L {
    fn reverse(bytes calldata _b) internal pure -> (bytes1, bytes1) {
        return (_b[1], _b[0]);
    }
}

contract C {
    using L for bytes;

    fn test(u256, bytes calldata _b, u256) external pure -> (bytes1, bytes1) {
        return _b.reverse();
    }
}

// ====
// compileViaYul: also
// ----
// test(u256,bytes,u256): 7, 0x60, 4, 2, "ab" -> "b", "a"
