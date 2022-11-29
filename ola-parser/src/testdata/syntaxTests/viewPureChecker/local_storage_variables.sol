contract C {
    struct S { u256 a; }
    S s;
    fn f() view  {
        S storage x = s;
        x;
    }
    fn g() view  {
        S storage x = s;
        x = s;
    }
    fn i()  {
        s.a = 2;
    }
    fn h()  {
        S storage x = s;
        x.a = 2;
    }
}
// ----
