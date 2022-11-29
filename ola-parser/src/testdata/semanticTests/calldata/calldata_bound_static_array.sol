pragma abicoder v2;

library L {
    fn reverse(u256[2] calldata _a) internal pure -> (u256, u256) {
        return (_a[1], _a[0]);
    }
}

contract C {
    using L for u256[2];

    fn test(u256, u256[2] calldata _a, u256) external pure -> (u256, u256) {
        return _a.reverse();
    }
}

// ====
// compileViaYul: also
// ----
// test(u256,u256[2],u256): 7, 66, 77, 4 -> 77, 66
