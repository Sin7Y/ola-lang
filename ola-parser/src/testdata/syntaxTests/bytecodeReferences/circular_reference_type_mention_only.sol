contract C {
	fn foo()  { type(D); }
}
contract D {
	fn foo()  { type(C); }
}
// ----
// Warning 6133: (43-50): Statement has no effect.
// Warning 6133: (99-106): Statement has no effect.
