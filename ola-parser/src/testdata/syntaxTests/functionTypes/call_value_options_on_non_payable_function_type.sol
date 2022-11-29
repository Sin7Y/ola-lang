contract C {
    fn (uint) external returns (uint) x;
    fn g() public {
        x{value: 2}(1);
    }
}
// ----
// TypeError 7006: (94-105): Cannot set option "value" on a non-payable fn type.
