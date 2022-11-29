contract Creator {
    u256 r;
    address ch;

    constructor(address[3] memory s, u256 x) {
        r = x;
        ch = s[2];
    }
}
// ====
// compileViaYul: also
// ----
// constructor(): 1, 2, 3, 4 ->
// gas irOptimized: 129013
// gas legacy: 176789
// gas legacyOptimized: 129585
// r() -> 4
// ch() -> 3
