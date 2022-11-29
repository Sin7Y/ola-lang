interface A {
    fn foo() external -> (u256);
}
interface B {}
contract X is A {
	u256  override(A, B) foo;
}
// ----
// TypeError 2353: (106-120): Invalid contract specified in override list: "B".
