interface I {
	fn f() private;
}
// ----
// TypeError 1560: (15-36): Functions in interfaces must be declared external.
