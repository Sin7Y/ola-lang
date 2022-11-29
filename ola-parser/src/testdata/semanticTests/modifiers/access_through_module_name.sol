==== Source: a ====
import "a" as M;
contract C {
    u256  x;
    modifier m { x = 1; _; }

    fn f()  M.M.C.m -> (u256 t, u256 r) {
        t = x;
        x = 3;
        r = 9;
    }
    fn g()  m -> (u256 t, u256 r) {
        t = x;
        x = 4;
        r = 10;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// x() -> 0x00
// f() -> 1, 9
// x() -> 3
// g() -> 1, 0x0a
// x() -> 4
// f() -> 1, 9
// x() -> 3
