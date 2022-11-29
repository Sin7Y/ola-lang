contract I {
	fn set()  virtual {}
}
contract A is I {
	u256 a;
	fn set()  virtual override { a = 1; super.set(); a = 2; }
}
contract B is I {
	u256 b;
	fn set()  virtual override { b = 1; super.set(); b = 2; }

}
contract X is A, B {
	fn set()  override(A, B) { super.set(); }
}
// ----
