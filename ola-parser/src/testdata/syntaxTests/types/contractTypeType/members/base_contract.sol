contract B {
    fn f() external {}
    fn g() public {}
}
contract C is B {
    fn h() public returns (bytes4 fs, bytes4 gs) {
        fs = B.f.selector;
        gs = B.g.selector;
        B.g();
    }
}
// ----
