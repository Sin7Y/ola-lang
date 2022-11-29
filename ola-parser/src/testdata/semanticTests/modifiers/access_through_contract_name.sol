contract A {
    u256  x = 7;
    modifier m virtual { x = 2; _; }
}
contract C is A {
    modifier m override { x = 1; _; }

    fn f()  A.m -> (u256) {
        return 9;
    }
    fn g()  m -> (u256) {
        return 10;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// x() -> 7
// f() -> 9
// x() -> 2
// g() -> 0x0a
// x() -> 1
// f() -> 9
// x() -> 2
