contract C {
    fn f() public pure returns(address payable[] memory m) {
        m = new address payable[](10);
    }
}
// ----
