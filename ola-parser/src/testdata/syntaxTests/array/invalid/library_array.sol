library L {}
contract C {
	fn f() public {
		L[] memory x;
	}
}
// ----
// TypeError 1130: (51-52): Invalid use of a library name.
