contract A {
    fn f() private {}
}

contract B {
    fn g() external {
        A.f;
    }
}
// ----
// TypeError 9582: (93-96): Member "f" not found or not visible after argument-dependent lookup in type(contract A).
