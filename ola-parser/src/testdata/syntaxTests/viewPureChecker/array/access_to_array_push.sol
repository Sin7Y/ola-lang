contract A {
    u256[] x;
    fn g()  -> (u256) {
        return x.push();
    }
}
// ----
