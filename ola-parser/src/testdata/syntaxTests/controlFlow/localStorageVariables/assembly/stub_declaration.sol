contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure {
        S storage c;
        assembly {
            c.slot := s.slot
        }
        c;
    }
}
// ----
