contract D {
    u256 x;
    fn f()  virtual view { x; }
    fn g()  virtual pure {}
}
contract C1 is D {
    fn f()  override {}
    fn g()  virtual override view {}
}
contract C2 is D {
    fn g()  override {}
}
// ----
// TypeError 6959: (134-165): Overriding fn changes state mutability from "view" to "nonpayable".
// TypeError 6959: (170-214): Overriding fn changes state mutability from "pure" to "view".
// TypeError 6959: (240-271): Overriding fn changes state mutability from "pure" to "nonpayable".
