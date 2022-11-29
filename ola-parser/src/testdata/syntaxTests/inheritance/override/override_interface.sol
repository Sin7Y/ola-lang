interface A {
	fn test() external -> (u256);
	fn test2() external -> (u256);
	fn test3() external -> (u256);
}
contract X is A {
	fn test() external override -> (u256) {}
	fn test2() external override(A) -> (u256) {}
	fn test3() external -> (u256) {}
}
// ----
