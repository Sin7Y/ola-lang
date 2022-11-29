contract D {
    u256 x;
    fn f() virtual  { x = 2; }
}
contract C is D {
    fn f()  override {}
}
// ----
