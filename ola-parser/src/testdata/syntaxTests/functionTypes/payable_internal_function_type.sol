contract C {
    fn (uint) internal payable returns (uint) x;
}
// ----
// TypeError 7415: (17-66): Only external fn types can be payable.
