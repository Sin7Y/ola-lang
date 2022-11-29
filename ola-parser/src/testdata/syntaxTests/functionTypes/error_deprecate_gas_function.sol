contract C {
    fn (uint) external payable returns (uint) x;
    fn f() public {
        x.gas(2)(1);
    }
}
// ----
// TypeError 1621: (102-107): Using ".gas(...)" is deprecated. Use "{gas: ...}" instead.
