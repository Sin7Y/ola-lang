contract C {
    fn (uint) external payable returns (uint) x;
    fn f() public {
        x{value: 2}(1);
    }
}
// ----
