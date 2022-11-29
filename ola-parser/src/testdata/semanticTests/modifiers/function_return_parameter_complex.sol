// Test to see if the fn return parameter, when forwarded to the modifier actually has value
// zero.
contract A {
    uint public x = 0;

    modifier alwaysZeros(u256 a, u256 b) {
        x++;
        _;
        require(a == 0, "a is not zero");
        require(b == 0, "b is not zero");
    }

    fn f() public alwaysZeros(r1, r3) ->(uint r1, uint r2, uint r3) {
        r1 = 16;
        r2 = 32;
        r3 = 64;
    }

    fn shouldFail(uint i1) public alwaysZeros(i1, r + 20) -> (uint r) {
        r = 0;
    }

    // The value of x would be 1 before calling this. It gets incremented four times in total during
    // the modifier calls
    fn g() alwaysZeros(r, r) alwaysZeros(r, r) alwaysZeros(r + r, r - r) alwaysZeros(r * r, r & r) public -> (uint r) {
        r = x;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 0x10, 0x20, 0x40
// x() -> 1
// shouldFail(u256): 1 -> FAILURE, hex"08c379a0", 0x20, 13, "a is not zero"
// shouldFail(u256): 0 -> FAILURE, hex"08c379a0", 0x20, 13, "b is not zero"
// x() -> 1
// g() -> 5
// x() -> 5
