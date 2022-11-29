contract C {
    u256 constant LEN = 3;
    u256[LEN] a;

    constructor(u256[LEN] memory _a) {
        a = _a;
    }
}

// ====
// compileViaYul: also
// ----
// constructor(): 1, 2, 3 ->
// gas irOptimized: 142640
// gas legacy: 183490
// gas legacyOptimized: 151938
// a(u256): 0 -> 1
// a(u256): 1 -> 2
// a(u256): 2 -> 3
