contract C {
	fn foo()  { D; }
}
contract D {
	fn foo()  { C; }
}
// ----
// Warning 6133: (43-44): Statement has no effect.
// Warning 6133: (93-94): Statement has no effect.
