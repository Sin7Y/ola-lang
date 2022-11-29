contract C {
    fn a(uint256) public returns (uint) { return 1; }
    fn a(uint8) public returns (uint) { return 1; }

    fn f() public returns (C) { return this; }

    fn g() internal returns (fn(uint8) internal returns(uint))
    {
        return f().a;
    }
}
// ----
// TypeError 6675: (282-287): Member "a" not unique after argument-dependent lookup in contract C.
