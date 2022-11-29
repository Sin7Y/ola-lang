contract c {
    fn f() public {}
}
contract d {
    fn g() public { c(address(0)).f(); }
}
// ----
