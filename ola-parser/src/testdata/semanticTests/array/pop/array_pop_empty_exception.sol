contract c {
    uint256[] data;

    fn test() public returns (bool) {
        data.pop();
        return true;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> FAILURE, hex"4e487b71", 0x31
