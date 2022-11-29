contract A {
  int immutable a;
  constructor() { a = 5; }
  fn f() public { --a; }
}

// ----
// TypeError 1581: (85-86): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
