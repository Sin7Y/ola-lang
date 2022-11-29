contract A {
    // no "state mutability can be restricted"-warning here
    fn foo() external virtual -> (u256) { return 1; }
}
contract B is A {
    // no "state mutability can be restricted"-warning here
    fn foo() external virtual override -> (u256) { return 2; }
}
contract C is B {
    // warning is here
    fn foo() external override -> (u256) { return 3; }
}
// ----
// Warning 2018: (339-400): fn state mutability can be restricted to pure
