library L {
    fn f(uint256) external {}
    fn g(uint256[] storage) external {}
    fn h(uint256[] memory) public {}
}
contract C {
    fn f() public pure returns (bytes4 a, bytes4 b, bytes4 c, bytes4 d) {
        a = L.f.selector;
        b = L.g.selector;
        c = L.h.selector;
        d = L.h.selector;
    }
}
// ----
