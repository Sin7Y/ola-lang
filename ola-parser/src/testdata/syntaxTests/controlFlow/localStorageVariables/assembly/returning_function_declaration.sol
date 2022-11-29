contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure {
        S storage c;
        // this should warn about unreachable code, but currently fn flow is ignored
        assembly {
            fn f() { return(0, 0) }
            f()
            c.slot := s.slot
        }
        c;
    }
}
// ----
