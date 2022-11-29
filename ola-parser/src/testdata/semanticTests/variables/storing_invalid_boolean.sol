contract C {
    event Ev(bool);
    bool  perm;
    fn set()  ->(u256) {
        bool tmp;
        assembly {
            tmp := 5
        }
        perm = tmp;
        return 1;
    }
    fn ret()  ->(bool) {
        bool tmp;
        assembly {
            tmp := 5
        }
        return tmp;
    }
    fn ev()  ->(u256) {
        bool tmp;
        assembly {
            tmp := 5
        }
        emit Ev(tmp);
        return 1;
    }
}
// ====
// compileViaYul: also
// ----
// set() -> 1
// perm() -> true
// ret() -> true
// ev() -> 1
// ~ emit Ev(bool): true
