contract C {
    fn(bytes calldata) -> (bytes1) x;
    constructor() { x = f; }
    fn f(bytes calldata b) internal pure -> (bytes1) {
        return b[2];
    }
    fn h(bytes calldata b) external -> (bytes1) {
        return x(b);
    }
    fn g() external -> (bytes1) {
        bytes memory a = new bytes(34);
        a[2] = bytes1(uint8(7));
        return this.h(a);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 0x0700000000000000000000000000000000000000000000000000000000000000
