contract base {
    fn f() private {}
}
contract derived is base {
    fn g() public { base.f(); }
}
// ----
// TypeError 9582: (99-105): Member "f" not found or not visible after argument-dependent lookup in type(contract base).
