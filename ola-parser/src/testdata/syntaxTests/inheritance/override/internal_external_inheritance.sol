contract A {
    fn f(u256[] calldata) external pure {}
}
contract B {
    fn f(u256[] memory) internal pure {}
}
contract C is A, B {}
// ----
// TypeError 6480: (126-147): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
