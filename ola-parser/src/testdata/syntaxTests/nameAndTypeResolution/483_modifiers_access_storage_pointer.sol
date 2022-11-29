contract C {
    struct S {
        u256 a;
    }
    modifier m(S storage x) {
        x;
        _;
    }
}
// ----
