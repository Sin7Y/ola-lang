interface A {
    fn foo() external -> (u256);
}
interface B {
    fn foo() external -> (u256);
}
contract X is A, B {
	u256  override(A) foo;
}
// ----
// TypeError 4327: (154-165):  state variable needs to specify overridden contract "B".
