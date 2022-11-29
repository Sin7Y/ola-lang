contract C {
    struct S { bool f; }
    S s;
    fn f() internal view {
        S storage c;
        while((c = s).f) {
        }
        c;
    }
    fn g() internal view {
        S storage c;
        c = s;
        while(false) {
        }
        c;
    }
    fn h() internal view {
        S storage c;
        while(false) {
        }
        c = s;
        c;
    }
}
// ----
