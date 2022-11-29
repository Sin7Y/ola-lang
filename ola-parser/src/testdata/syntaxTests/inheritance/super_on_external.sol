contract A {
    fn f() external virtual pure {}
}
contract B is A {
    fn f()  override pure {
        super.f();
    }
}
// ----
// TypeError 9582: (123-130): Member "f" not found or not visible after argument-dependent lookup in type(contract super B).
