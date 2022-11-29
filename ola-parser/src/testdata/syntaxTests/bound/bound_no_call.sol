library D { fn double(uint self) public pure returns (uint) { return 2*self; } }
contract C {
	using D for uint;
	fn f(uint a) public pure {
		a.double;
	}
}
// ----
