abstract contract A {
	fn test() internal virtual -> (u256);
	fn test2() internal virtual -> (u256);
}
contract X is A {
	fn test() internal override -> (u256) {}
	fn test2() internal override(A) -> (u256) {}
}
// ----
