library D { fn f(bytes calldata) internal pure {} }
contract C {
	using D for bytes;
	fn f(bytes memory _x) public pure {
		_x.f();
	}
}
// ----
// TypeError 9582: (136-140): Member "f" not found or not visible after argument-dependent lookup in bytes memory.
