contract C {
    struct S { uint a; string b; }
    S x;
    fn f() view public {
        S storage y = x;
        y;
    }
}
// ----
