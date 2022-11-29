library L {
    fn value(fn()internal a, uint256 b) internal {}
}
contract C {
    using L for fn()internal;
    fn f() public {
        fn()internal x;
        x.value(42);
    }
}
// ----
