contract A {
    fn f() external {}
    fn f(uint256) external {}
}

contract B {
    fn g() external {
        A.f;
    }
}
// ----
// TypeError 6675: (130-133): Member "f" not unique after argument-dependent lookup in type(contract A).
