abstract contract C {
    fn foo() external pure virtual -> (u256);
}
contract X is C {
	u256  constant override foo = 7;
}
// ----
