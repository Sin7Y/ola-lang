contract C {
    modifier callAndRevert() {
        _;
        revert();
    }
    modifier ifFlag(bool flag) {
        if (flag)
            _;
    }
    struct S { uint a; }
    S s;
    fn f(bool flag) callAndRevert() internal view returns(S storage) {
        if (flag) return s;
    }
    fn g(bool flag) callAndRevert() ifFlag(flag) internal view returns(S storage) {
        return s;
    }

}
// ----
