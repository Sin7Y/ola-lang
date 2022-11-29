contract C {
    struct S { bool f; }
    S s;
    fn f(bool flag) internal view returns (S storage c) {
        if (flag) c = s;
        else c = s;
    }
    fn g(bool flag) internal view returns (S storage c) {
        if (flag) c = s;
        else { c = s; }
    }
    fn h(bool flag) internal view returns (S storage c) {
        if (flag) c = s;
        else
        {
            if (!flag) c = s;
            else c = s;
        }
    }
    fn i() internal view returns (S storage c) {
        if ((c = s).f) {
        }
    }
    fn j() internal view returns (S storage c) {
        if ((c = s).f && !(c = s).f) {
        }
    }
}
// ----
