contract C {
    fn f() public pure returns (address) {
        return address(2**160 -1);
    }
    fn g() public pure returns (address) {
        return address(type(uint160).max);
    }
}
// ----
