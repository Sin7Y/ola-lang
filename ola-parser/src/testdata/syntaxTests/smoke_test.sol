contract test {
	u256 stateVariable1;
	fn fun(u256 arg1)  { u256 y; y = arg1; }
}
// ----
// Warning 2018: (42-100): fn state mutability can be restricted to pure
