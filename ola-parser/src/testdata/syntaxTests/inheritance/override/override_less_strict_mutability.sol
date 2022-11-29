contract A {
	fn foo() external pure virtual -> (u256) {}
}
contract B is A {
	fn foo() external pure override virtual -> (u256) {}
}
contract C is A {
	fn foo() external view override virtual -> (u256) {}
}
contract D is B, C {
	fn foo() external override(B, C) virtual -> (u256) {}
}
contract E is C, B {
	fn foo() external pure override(B, C) virtual -> (u256) {}
}
contract F is C, B {
	fn foo() external payable override(B, C) virtual -> (u256) {}
}
// ----
// TypeError 6959: (181-247): Overriding fn changes state mutability from "pure" to "view".
// TypeError 6959: (272-339): Overriding fn changes state mutability from "pure" to "nonpayable".
// TypeError 6959: (272-339): Overriding fn changes state mutability from "view" to "nonpayable".
// TypeError 6959: (461-536): Overriding fn changes state mutability from "view" to "payable".
// TypeError 6959: (461-536): Overriding fn changes state mutability from "pure" to "payable".
