==== Source: SourceName ====
contract A {
	u256 x;
	fn f()  { x = 42; }
}
// ----
// TypeError 8961: (SourceName:53-54): fn cannot be declared as pure because this expression (potentially) modifies the state.
