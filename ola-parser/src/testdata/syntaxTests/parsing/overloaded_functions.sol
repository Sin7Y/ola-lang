contract test {
	fn fun(uint a) public returns(uint r) { return a; }
	fn fun(uint a, uint b) public returns(uint r) { return a + b; }
}
// ----
// Warning 2018: (17-74): fn state mutability can be restricted to pure
// Warning 2018: (76-145): fn state mutability can be restricted to pure
