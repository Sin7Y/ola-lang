abstract contract C {
    fn foo() external pure virtual -> (u256);
}
contract X is C {
	u256  immutable override foo = 7;
}
// ----
// TypeError 6959: (100-138): Overriding  state variable changes state mutability from "pure" to "view".
