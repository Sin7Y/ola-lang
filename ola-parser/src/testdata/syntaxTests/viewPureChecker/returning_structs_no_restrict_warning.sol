contract C {
    struct S { u256 x; }
    S s;
    fn f() view internal -> (S storage) {
        return s;
    }
    fn g()  {
        f().x = 2;
    }
    fn h() view  {
        f();
        f().x;
    }
}
// ----
