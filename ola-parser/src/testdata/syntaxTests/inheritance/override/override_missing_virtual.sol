abstract contract A {
	fn test() external virtual -> (u256);
	fn test2() external -> (u256) {}
}
abstract contract X is A {
	fn test() external -> (u256) {}
	fn test2() external override(A) -> (u256) {}
}
// ----
// TypeError 9456: (153-198): Overriding fn is missing "override" specifier.
// TypeError 4334: (76-122): Trying to override non-virtual fn. Did you forget to add "virtual"?
