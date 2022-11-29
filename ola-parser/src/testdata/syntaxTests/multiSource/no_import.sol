==== Source: A ====
contract A {
	fn g(u256 x)  ->(u256) { return x; }
}
==== Source: B ====
contract B is A {
	fn f(u256 x)  ->(u256) { return x; }
}
// ----
// DeclarationError 7920: (B:14-15): Identifier not found or not unique.
