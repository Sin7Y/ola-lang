contract C {
    address a;
    fn f(address b) public pure returns (address c) {
        address d = b;
        return d;
    }
}
// ----
