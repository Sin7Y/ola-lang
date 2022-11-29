library L {
}
contract C {
    fn f() public pure returns (address) {
        return address(L);
    }
}
// ----
