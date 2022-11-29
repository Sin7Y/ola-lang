contract base {
    fn f() external {}
}
contract derived is base {
    fn g() public { base.f(); }
}
// ----
// TypeError 3419: (100-108): Cannot call fn via contract type name.
