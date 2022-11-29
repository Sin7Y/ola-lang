contract C {
    fn f() public pure returns (bool) {
        return abi.decode("abc", (uint)) == 2;
    }
}
// ----
