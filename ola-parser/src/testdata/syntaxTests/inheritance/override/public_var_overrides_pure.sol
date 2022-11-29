abstract contract C {
    fn foo() external pure virtual -> (u256);
}
contract X is C {
	u256  override foo;
}
// ----
// TypeError 6959: (100-124): Overriding  state variable changes state mutability from "pure" to "view".
