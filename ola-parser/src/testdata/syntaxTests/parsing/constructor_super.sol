contract A {
  fn x() pure internal {}
}

contract B is A {
  constructor() {
    // used to trigger warning about using ``this`` in constructor
    super.x();
  }
}
// ----
