abstract contract C {
	fn f() external;
}
// ----
// TypeError 5424: (23-45): Functions without implementation must be marked virtual.
