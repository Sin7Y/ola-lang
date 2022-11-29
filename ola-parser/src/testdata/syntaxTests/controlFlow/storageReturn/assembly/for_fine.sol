contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure returns (S storage c) {
        assembly {
            for { c.slot := s.slot } iszero(0) {} {}
        }
    }
    fn g() internal pure returns (S storage c) {
        assembly {
            for { c.slot := s.slot } iszero(1) {} {}
        }
    }
}
// ----
