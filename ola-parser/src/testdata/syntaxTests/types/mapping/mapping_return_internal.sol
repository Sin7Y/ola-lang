contract C {
    mapping(uint=>uint) m;
    fn f() internal view returns (mapping(uint=>uint) storage) {
        return m;
    }
    fn g() private view returns (mapping(uint=>uint) storage) {
        return m;
    }
    fn h() internal view returns (mapping(uint=>uint) storage r) {
        r = m;
    }
    fn i() private view returns (mapping(uint=>uint) storage r) {
        (r,r) = (m,m);
    }
}
// ----
