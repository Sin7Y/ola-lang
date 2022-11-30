contract Test {
    uint128[13] unused;
    u256[][] a;
    u256[4][] b;
    u256[2][3] c;

    fn test() external -> (u256) {
        u256[][] memory m = new u256[][](2);
        m[0] = new u256[](3);
        m[0][0] = 7; m[0][1] = 8; m[0][2] = 9;
        m[1] = new u256[](4);
        m[1][1] = 7; m[1][2] = 8; m[1][3] = 9;
        a = m;
        return a[0][0] + a[0][1] + a[1][3];
    }

    fn test1() external -> (u256) {
        u256[2][] memory m = new u256[2][](1);
        m[0][0] = 1; m[0][1] = 2;
        b = m;
        return b[0][0] + b[0][1];
    }

    fn test2() external -> (u256) {
        u256[2][2] memory m;
        m[0][0] = 1; m[1][1] = 2; m[0][1] = 3;
        c = m;
        return c[0][0] + c[1][1] + c[0][1];
    }

    fn test3() external -> (u256) {
        u256[2][3] memory m;
        m[0][0] = 7; m[1][0] = 8; m[2][0] = 9;
        m[0][1] = 7; m[1][1] = 8; m[2][1] = 9;
        a = m;
        return a[0][0] + a[1][0] + a[2][1];
    }
}
// ====
// compileViaYul: also
// ----
// test() -> 24
// gas irOptimized: 227133
// gas legacy: 227133
// gas legacyOptimized: 226547
// test1() -> 3
// test2() -> 6
// test3() -> 24
// gas irOptimized: 133590
// gas legacy: 134295
// gas legacyOptimized: 133383
