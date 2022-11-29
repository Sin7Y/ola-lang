contract C {
    fn f()  -> (u256) {
        return address(this).balance;
    }
    fn g()  -> (u256) {
        return address(0).balance;
    }
}
// ----
