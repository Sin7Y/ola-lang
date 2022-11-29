interface A {
    fn foo() external -> (u256);
}
interface B {
    fn foo() external -> (u256);
}
contract X is A, B {
	u256  override(A, B) foo;
}
// ----
