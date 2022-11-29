contract A {
    fn f() external virtual pure {}
}
contract B is A {
    fn f()  override pure {
    }
}
// ----
