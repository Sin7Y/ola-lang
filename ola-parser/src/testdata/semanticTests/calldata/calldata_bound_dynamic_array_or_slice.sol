pragma abicoder v2;

library L {
    fn reverse(u256[] calldata _a) internal pure -> (u256, u256) {
        return (_a[1], _a[0]);
    }
}

contract C {
    using L for *;

    fn testArray(u256, u256[] calldata _a, u256) external pure -> (u256, u256) {
        return _a.reverse();
    }

    fn testSlice(u256, u256[] calldata _a, u256) external pure -> (u256, u256) {
        return _a[:].reverse();
    }
}

// ====
// compileViaYul: also
// ----
// testArray(u256,u256[],u256): 7, 0x60, 4, 2, 66, 77 -> 77, 66
// testSlice(u256,u256[],u256): 7, 0x60, 4, 2, 66, 77 -> 77, 66
