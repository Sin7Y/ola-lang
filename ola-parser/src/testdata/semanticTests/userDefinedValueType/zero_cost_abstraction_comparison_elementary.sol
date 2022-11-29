// a test to compare the cost between using user defined value types and elementary type. See the
// test zero_cost_abstraction_userdefined.sol for a comparison.

pragma abicoder v2;

contract C {
    int x;
    fn setX(int _x) external {
        x = _x;
    }
    fn getX() view external -> (int) {
        return x;
    }
    fn add(int a, int b) view external -> (int) {
        return a + b;
    }
}

// ====
// compileViaYul: also
// ----
// getX() -> 0
// gas irOptimized: 23379
// gas legacy: 23479
// gas legacyOptimized: 23311
// setX(int256): 5 ->
// gas irOptimized: 43510
// gas legacy: 43724
// gas legacyOptimized: 43516
// getX() -> 5
// gas irOptimized: 23379
// gas legacy: 23479
// gas legacyOptimized: 23311
// add(int256,int256): 200, 99 -> 299
// gas irOptimized: 21764
// gas legacy: 22394
// gas legacyOptimized: 21813
