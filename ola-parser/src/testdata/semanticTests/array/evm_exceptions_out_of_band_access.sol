contract A {
    u256[3] arr;
    bool public test = false;

    fn getElement(u256 i) public -> (u256) {
        return arr[i];
    }

    fn testIt() public -> (bool) {
        u256 i = this.getElement(5);
        test = true;
        return true;
    }
}
// ====
// compileViaYul: also
// ----
// test() -> false
// testIt() -> FAILURE, hex"4e487b71", 0x32
// test() -> false
