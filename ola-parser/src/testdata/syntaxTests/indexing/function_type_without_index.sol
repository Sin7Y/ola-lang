contract C {
  fn f()  {
    f[];
  }
}
// ----
// TypeError 2614: (41-42): Indexed expression has to be a type, mapping or array (is fn ())
