contract C {
    fn (uint) external payable returns (uint) x;
    fn f() public {
        x.value(2)(1);
    }
}
// ----
// TypeError 1621: (102-109): Using ".value(...)" is deprecated. Use "{value: ...}" instead.
