interface I {
	fn f() external;
	fn g() external;
	fn h() external;
}
contract C is I {
	fn f() external {}
	fn g() external override {}
	fn h() external override(I) {}
}
// ----
