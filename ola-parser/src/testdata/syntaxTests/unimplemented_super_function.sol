abstract contract a {
    fn f() virtual ;
}
contract b is a {
    fn f()  override { super.f(); }
}
// ----
// TypeError 9582: (110-117): Member "f" not found or not visible after argument-dependent lookup in type(contract super b).
