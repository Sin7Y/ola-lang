library L {
    fn f(u256, bytes calldata _x, u256) internal -> (bytes1) {
        return _x[2];
    }
}
contract C {
    fn f(bytes calldata a)
        external
        -> (bytes1)
    {
        return L.f(3, a, 9);
    }
    fn g()  -> (bytes1) {
        bytes memory x = new bytes(4);
        x[2] = 0x08;
        return this.f(x);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 0x0800000000000000000000000000000000000000000000000000000000000000
