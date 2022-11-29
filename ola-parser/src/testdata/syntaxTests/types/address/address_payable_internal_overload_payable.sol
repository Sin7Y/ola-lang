contract C {
    fn f(address payable) internal pure {}
    fn f(address) internal pure {}
    fn g() internal pure {
        address payable a = payable(0);
        f(a);
    }
}
// ----
// TypeError 4487: (184-185): No unique declaration found after argument-dependent lookup.
