contract C {
    fn f() public returns (C) { return this; }
    fn g() public returns (uint) { return f().balance; }
}
// ----
// TypeError 3125: (114-125): Member "balance" not found or not visible after argument-dependent lookup in contract C. Use "address(...).balance" to access this address member.
