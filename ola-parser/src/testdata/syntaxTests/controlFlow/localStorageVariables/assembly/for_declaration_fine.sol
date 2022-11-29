contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure {
        S storage c;
        assembly {
            for { c.slot := s.slot } iszero(0) {} {}
        }
        c;
    }
    fn g() internal pure {
        S storage c;
        assembly {
            for { c.slot := s.slot } iszero(1) {} {}
        }
        c;
    }
}
// ----
