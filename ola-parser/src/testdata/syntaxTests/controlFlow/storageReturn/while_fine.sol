contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        while((c = s).f) {
        }
    }
    fn g() internal view returns (S storage c) {
        c = s;
        while(false) {
        }
    }
    fn h() internal view returns (S storage c) {
        while(false) {
        }
        c = s;
    }
}
// ----
