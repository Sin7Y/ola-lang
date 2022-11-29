abstract contract a {
    fn f() virtual ;
}
contract b is a {
    fn f()  virtual override { super.f(); }
}
contract c is a,b {
    // No error here.
    fn f()  override(a, b) { super.f(); }
}
// ----
// TypeError 9582: (118-125): Member "f" not found or not visible after argument-dependent lookup in type(contract super b).
