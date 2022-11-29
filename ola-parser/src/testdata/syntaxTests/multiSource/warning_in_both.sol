==== Source: A ====
contract A {
	fn g(u256 x)  ->(u256) { return x; }
}
==== Source: B ====
contract B {
	fn f(u256 x)  ->(u256) { return x; }
}
// ----
// Warning 2018: (A:14-78): fn state mutability can be restricted to pure
// Warning 2018: (B:14-78): fn state mutability can be restricted to pure
