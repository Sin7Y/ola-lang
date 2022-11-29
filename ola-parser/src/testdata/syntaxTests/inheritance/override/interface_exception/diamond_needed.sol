interface I {
	fn f() external;
	fn g() external;
	fn h() external;
}
interface J {
	fn f() external;
	fn g() external;
	fn h() external;
}
contract C is I, J {
	fn f() external {}
	fn g() external override {}
	fn h() external override(I) {}
}
// ----
// TypeError 4327: (198-222): fn needs to specify overridden contracts "I" and "J".
// TypeError 4327: (246-254): fn needs to specify overridden contracts "I" and "J".
// TypeError 4327: (281-292): fn needs to specify overridden contract "J".
