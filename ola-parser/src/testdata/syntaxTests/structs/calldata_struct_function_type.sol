pragma abicoder               v2;
contract C {
    struct S { fn (uint) external returns (uint) fn; }
    fn f(S calldata s) external returns (uint256 a) {
        return s.fn(42);
    }
}
// ----
