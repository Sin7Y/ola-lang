contract C {
    uint[] data;
    fn f(uint[] memory x) public {
        data = x;
    }
}
// ----
