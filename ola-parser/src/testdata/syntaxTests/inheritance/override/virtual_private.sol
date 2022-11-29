abstract contract A {
	fn test() private virtual -> (u256);
}
abstract contract X is A {
	fn test() private override -> (u256) {}
}
// ----
// TypeError 3942: (23-73): "virtual" and "private" cannot be used together.
