contract C {
    mapping(u256 => u256) a;
    fn f() view  {
        a;
    }
    fn g() view  {
        a[2];
    }
    fn h()  {
        a[2] = 3;
    }
}
// ----
