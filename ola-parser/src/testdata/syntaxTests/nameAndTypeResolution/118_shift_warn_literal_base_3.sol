contract test {
    fn f() pure public returns(uint) {
        return 2 << 80;
    }
}
// ----
