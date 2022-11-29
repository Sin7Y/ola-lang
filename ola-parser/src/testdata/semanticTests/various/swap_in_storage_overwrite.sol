// This tests a swap in  which does not work as one
// might expect because we do not have temporary .
// (x, y) = (y, x) is the same as
// y = x;
// x = y;
contract c {
    struct S {
        u256 a;
        u256 b;
    }
    S  x;
    S  y;

    fn set()  {
        x.a = 1;
        x.b = 2;
        y.a = 3;
        y.b = 4;
    }

    fn swap()  {
        (x, y) = (y, x);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// x() -> 0, 0
// y() -> 0, 0
// set() ->
// gas irOptimized: 109713
// gas legacy: 109732
// gas legacyOptimized: 109682
// x() -> 1, 2
// y() -> 3, 4
// swap() ->
// x() -> 1, 2
// y() -> 1, 2
