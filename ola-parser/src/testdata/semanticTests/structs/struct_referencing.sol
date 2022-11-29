pragma abicoder v2;
interface I {
    struct S { u256 a; }
}

library L {
    struct S { u256 b; u256 a; }
    fn f()  -> (S memory) {
        S memory s;
        s.a = 3;
        return s;
    }
    fn g()  -> (I.S memory) {
        I.S memory s;
        s.a = 4;
        return s;
    }
    // argument-dependant lookup tests
    fn a(I.S memory)  -> (u256) { return 1; }
    fn a(S memory)  -> (u256) { return 2; }
}

contract C is I {
    fn f()  -> (S memory) {
        S memory s;
        s.a = 1;
        return s;
    }
    fn g()  -> (I.S memory) {
        I.S memory s;
        s.a = 2;
        return s;
    }
    fn h()  -> (L.S memory) {
        L.S memory s;
        s.a = 5;
        return s;
    }
    fn x()  -> (L.S memory) {
        return L.f();
    }
    fn y()  -> (I.S memory) {
        return L.g();
    }
    fn a1()  -> (u256) { S memory s; return L.a(s); }
    fn a2()  -> (u256) { L.S memory s; return L.a(s); }
}
// ====
// compileToEwasm: false
// compileViaYul: also
// ----
// library: L
// f() -> 1
// g() -> 2
// f() -> 1
// g() -> 2
// h() -> 0, 5
// x() -> 0, 3
// y() -> 4
// a1() -> 1
// a2() -> 2
