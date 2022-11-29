contract C {
    fn value(uint256) public returns (uint) { return 1; }
    fn value(uint8) public returns (uint) { return 1; }

    fn f() public returns (C) { return this; }

    fn g() internal returns (fn(uint8) internal returns(uint))
    {
        return f().value;
    }
}
// ----
// TypeError 6675: (290-299): Member "value" not unique after argument-dependent lookup in contract C - did you forget the "payable" modifier?
