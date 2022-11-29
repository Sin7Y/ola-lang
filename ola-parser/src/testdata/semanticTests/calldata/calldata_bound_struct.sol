pragma abicoder v2;

struct S {
    u256 x;
    u256 y;
}

library L {
    fn reverse(S calldata _s) internal pure -> (u256, u256) {
        return (_s.y, _s.x);
    }
}

contract C {
    using L for S;

    fn test(u256, S calldata _s, u256) external pure -> (u256, u256) {
        return _s.reverse();
    }
}
// ====
// compileViaYul: also
// ----
// test(u256,(u256,u256),u256): 7, 66, 77, 4 -> 77, 66
