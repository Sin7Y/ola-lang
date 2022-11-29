contract test {
    fn fa(uint) public {}
    fn fb(uint) internal {}
    fn fc(uint) internal {}
    fn fd(uint) external {}
    fn fe(uint) external {}
    fn ff(uint) internal {}
    fn fg(uint) internal pure {}
    fn fh(uint) pure internal {}

    fn(uint) a = fa;
    fn(uint) internal b = fb; // (explicit internal applies to the fn type)
    fn(uint) internal internal c = fc;
    fn(uint) external d = this.fd;
    fn(uint) external internal e = this.fe;
    fn(uint) internal f = ff;
    fn(uint) internal pure g = fg;
    fn(uint) pure internal h = fh;
}
// ----
