interface A {
	fn test() external -> (u256);
	fn test2() external -> (u256);
}

interface B {
	fn test() external -> (u256);
	fn test2() external -> (u256);
}
contract X is A, B {
	fn test() external override(A, B) -> (u256) {}
	fn test2() external override(B, A) -> (u256) {}
}
// ----
