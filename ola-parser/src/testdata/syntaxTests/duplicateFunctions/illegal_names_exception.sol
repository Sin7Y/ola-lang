// Exception for the rule about illegal names.
contract C {
	fn this() public {
	}
	fn super() public {
	}
	fn _() public {
	}
}
// ----
// Warning 2319: (61-88): This declaration shadows a builtin symbol.
// Warning 2319: (90-118): This declaration shadows a builtin symbol.
