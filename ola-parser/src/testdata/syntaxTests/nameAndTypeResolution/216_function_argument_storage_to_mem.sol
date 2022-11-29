contract C {
    fn f(uint[] storage x) private {
        g(x);
    }
    fn g(uint[] memory x) public {
    }
}
// ----
