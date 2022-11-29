library L {}
contract C {
	fn f()  override (L) {}
}
// ----
// TypeError 1130: (57-58): Invalid use of a library name.
