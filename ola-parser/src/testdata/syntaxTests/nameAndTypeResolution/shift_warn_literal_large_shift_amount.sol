contract test {
    fn f() pure public returns(uint) {
        uint x = 100;
        return 10 << x;
    }
}
// ----
