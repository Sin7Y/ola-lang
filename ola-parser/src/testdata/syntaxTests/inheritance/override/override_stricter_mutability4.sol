contract A {
	fn foo()  payable virtual -> (u256) {}
}
contract B is A {
	fn foo()  override virtual -> (u256) {}
}
// ----
// TypeError 6959: (94-158): Overriding fn changes state mutability from "payable" to "view".
