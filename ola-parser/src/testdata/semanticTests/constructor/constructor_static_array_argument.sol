contract C {
    u256 public a;
    u256[3] public b;

    constructor(u256 _a, u256[3] memory _b) {
        a = _a;
        b = _b;
    }
}

// ====
// compileViaYul: also
// ----
// constructor(): 1, 2, 3, 4 ->
// gas irOptimized: 174020
// gas legacy: 221377
// gas legacyOptimized: 177671
// a() -> 1
// b(u256): 0 -> 2
// b(u256): 1 -> 3
// b(u256): 2 -> 4
