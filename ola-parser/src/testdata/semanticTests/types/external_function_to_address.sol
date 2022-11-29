contract C {
    fn f() public returns (bool) {
        return this.f.address == address(this);
    }
    fn g(fn() external cb) public returns (address) {
        return cb.address;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> true
// g(fn): hex"00000000000000000000000000000000000004226121ff00000000000000000" -> 0x42
