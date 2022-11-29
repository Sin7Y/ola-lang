contract C {
    struct S { bool f; }
    S s;
    fn f() internal view {
        S storage c;
        do {} while((c = s).f);
        c;
    }
    fn g() internal view {
        S storage c;
        do { c = s; } while(false);
        c;
    }
    fn h() internal view {
        S storage c;
        c = s;
        do {} while(false);
        c;
    }
    fn i() internal view {
        S storage c;
        do {} while(false);
        c = s;
        c;
    }
    fn j() internal view {
        S storage c;
        do {
            c = s;
            break;
        } while(false);
        c;
    }
    fn k() internal view {
        S storage c;
        do {
            c = s;
            continue;
        } while(false);
        c;
    }
}
// ----
// Warning 5740: (606-611): Unreachable code.
