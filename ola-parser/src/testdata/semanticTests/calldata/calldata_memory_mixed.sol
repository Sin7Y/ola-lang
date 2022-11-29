contract C {
    fn f(bytes memory _a, bytes calldata _b, bytes memory _c)
        
        -> (u256, bytes1, bytes1, bytes1)
    {
        return (_a.length + _b.length + _c.length, _a[1], _b[1], _c[1]);
    }
    fn g()  -> (u256, bytes1, bytes1, bytes1) {
        bytes memory x = new bytes(3);
        bytes memory y = new bytes(4);
        bytes memory z = new bytes(7);
        x[1] = 0x08;
        y[1] = 0x09;
        z[1] = 0x0a;
        return this.f(x, y, z);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 0x0e, 0x0800000000000000000000000000000000000000000000000000000000000000, 0x0900000000000000000000000000000000000000000000000000000000000000, 0x0a00000000000000000000000000000000000000000000000000000000000000
