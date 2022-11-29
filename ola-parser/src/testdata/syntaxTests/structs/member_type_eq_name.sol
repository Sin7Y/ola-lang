contract C {
  struct S {t t;}
  fn f(fn(S memory) external) public {}
}
// ----
// DeclarationError 7920: (25-26): Identifier not found or not unique.
