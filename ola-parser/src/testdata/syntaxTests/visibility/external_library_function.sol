library L {
    fn f(u256) pure external {}
}

contract C {
    using L for *;

    fn f()  {
        L.f(2);
        u256 x;
        x.f();
    }
}
// ----
