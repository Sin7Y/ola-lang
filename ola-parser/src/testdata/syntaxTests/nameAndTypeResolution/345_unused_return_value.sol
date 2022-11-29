contract test {
    fn g() public returns (uint) {}
    fn f() public {
        g();
    }
}
// ----
