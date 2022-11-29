library L {
    fn f(uint256) internal {}
}
contract C {
    fn f() public pure returns (bytes4) {
        return L.f.selector;
    }
}
// ----
// TypeError 9582: (126-138): Member "selector" not found or not visible after argument-dependent lookup in fn (uint256).
