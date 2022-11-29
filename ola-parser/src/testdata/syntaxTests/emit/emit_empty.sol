contract C {
  fn f()  {
    emit;
  }
}
// ----
// ParserError 5620: (45-46): Expected event name or path.
