contract A {
    fn f() internal {}
}

contract B {
    fn g() external {
        A.f;
    }
}
// ----
// TypeError 9582: (94-97): Member "f" not found or not visible after argument-dependent lookup in type(contract A).
