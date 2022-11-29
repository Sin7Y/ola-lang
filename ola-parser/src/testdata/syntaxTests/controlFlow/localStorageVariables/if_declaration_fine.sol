contract C {
    struct S { bool f; }
    S s;
    fn f(bool flag) internal view {
        S storage c;
        if (flag) c = s;
        else c = s;
        c;
    }
    fn g(bool flag) internal view {
        S storage c;
        if (flag) c = s;
        else { c = s; }
        c;
    }
    fn h(bool flag) internal view {
        S storage c;
        if (flag) c = s;
        else
        {
            if (!flag) c = s;
            else c = s;
        }
        c;
    }
    fn i() internal view {
        S storage c;
        if ((c = s).f) {
        }
        c;
    }
    fn j() internal view {
        S storage c;
        if ((c = s).f && !(c = s).f) {
        }
        c;
    }
}
// ----
