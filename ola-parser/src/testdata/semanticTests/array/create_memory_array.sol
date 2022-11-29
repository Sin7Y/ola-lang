contract C {
    struct S {
        u256[2] a;
        bytes b;
    }

    fn f() public -> (bytes1, u256, u256, bytes1) {
        bytes memory x = new bytes(200);
        x[199] = "A";
        u256[2][] memory y = new u256[2][](300);
        y[203][1] = 8;
        S[] memory z = new S[](180);
        z[170].a[1] = 4;
        z[170].b = new bytes(102);
        z[170].b[99] = "B";
        return (x[199], y[203][1], z[170].a[1], z[170].b[99]);
    }
}
// ====
// compileViaYul: also
// ----
// f() -> "A", 8, 4, "B"
// gas irOptimized: 130592
// gas legacy: 121398
// gas legacyOptimized: 115494
