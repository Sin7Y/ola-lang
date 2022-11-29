abstract contract A {
	fn foo() internal virtual -> (u256);
}

abstract contract B is A {
	fn foo() internal override virtual -> (u256);
}

abstract contract C is B {
	fn foo() internal override virtual -> (u256);
}

abstract contract D is C {
	fn foo() internal override virtual -> (u256);
}

contract X is D {
	fn foo() internal override -> (u256) {}
}
// ----
