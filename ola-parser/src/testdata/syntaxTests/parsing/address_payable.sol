contract C {
    address payable a;
    fn f(address payable b) public pure returns (address payable c) {
        address payable d = b;
        return d;
    }
}
// ----
