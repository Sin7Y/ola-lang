library L {
    fn f(uint256) external pure {}
    fn g(uint256) external view {}
}
contract C {
    fn f() public pure returns (bytes4, bytes4) {
        return (L.f.selector, L.g.selector);
    }
}
// ----
