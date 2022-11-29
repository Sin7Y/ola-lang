contract c {
    fn f() internal {}
}
contract d {
    fn g() public { c(address(0)).f(); }
}
// ----
// TypeError 9582: (83-98): Member "f" not found or not visible after argument-dependent lookup in contract c.
