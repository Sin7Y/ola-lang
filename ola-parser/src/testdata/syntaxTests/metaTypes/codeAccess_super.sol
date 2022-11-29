contract Other {
    fn f(u256)  -> (u256) {}
}
contract SuperTest is Other {
	fn creationSuper()  -> (bytes memory) {
		return type(super).creationCode;
	}
	fn runtimeOther()  -> (bytes memory) {
		return type(super).runtimeCode;
	}
}
// ----
// TypeError 4259: (177-182): Invalid type for argument in the fn call. An enum type, contract type or an integer type is required, but type(contract super SuperTest) provided.
