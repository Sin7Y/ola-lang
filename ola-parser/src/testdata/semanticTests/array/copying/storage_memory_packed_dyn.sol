contract C {
    uint8[] a;

    fn f()  -> (uint8, uint8, uint8) {
        for (u256 i = 0; i < 33; i++)
            a.push(7);
        a[0] = 2;
        a[16] = 3;
        a[32] = 4;
        uint8[] memory m = a;
        return (m[0], m[16], m[32]);
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 2, 3, 4
// gas irOptimized: 114114
// gas legacy: 126350
// gas legacyOptimized: 120704
