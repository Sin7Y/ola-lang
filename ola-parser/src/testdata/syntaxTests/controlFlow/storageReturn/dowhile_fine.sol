contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        do {} while((c = s).f);
    }
    fn g() internal view returns (S storage c) {
        do { c = s; } while(false);
    }
    fn h() internal view returns (S storage c) {
        c = s;
        do {} while(false);
    }
    fn i() internal view returns (S storage c) {
        do {} while(false);
        c = s;
    }
    fn j() internal view returns (S storage c) {
        do {
            c = s;
            break;
        } while(false);
    }
    fn k() internal view returns (S storage c) {
        do {
            c = s;
            continue;
        } while(false);
    }
}
// ----
// Warning 5740: (567-572): Unreachable code.
