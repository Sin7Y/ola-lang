contract Main {
    bytes3 name;
    bool flag;

    constructor(bytes3 x, bool f) {
        name = x;
        flag = f;
    }

    fn getName()  -> (bytes3 ret) {
        return name;
    }

    fn getFlag()  -> (bool ret) {
        return flag;
    }
}
// ====
// compileViaYul: also
// ----
// constructor(): "abc", true
// gas irOptimized: 106683
// gas legacy: 145838
// gas legacyOptimized: 104017
// getFlag() -> true
// getName() -> "abc"
