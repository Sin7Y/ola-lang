abstract contract I {
	fn f() external virtual;
}
contract C is I {
	fn f() external {}
}
// ----
// TypeError 9456: (75-99): Overriding fn is missing "override" specifier.
