contract B {
    fn f() external {}
    fn g() internal {}
}
contract C is B {
    fn i() public {
        B.f();
        B.g.selector;
    }
}
// ----
// TypeError 3419: (125-130): Cannot call fn via contract type name.
// TypeError 9582: (140-152): Member "selector" not found or not visible after argument-dependent lookup in fn ().
