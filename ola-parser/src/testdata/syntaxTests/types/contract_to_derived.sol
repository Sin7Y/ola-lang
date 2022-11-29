contract B {}
contract A is B {}
contract C {
  fn f() public pure {
    A a = A(new B());
  }
}
// ----
// TypeError 9640: (85-95): Explicit type conversion not allowed from "contract B" to "contract A".
