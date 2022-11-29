contract A {
	fn foo()  virtual -> (u256) {}
}
contract B is A {
	fn foo()  payable override virtual -> (u256) {}
}
// ----
// TypeError 6959: (91-158): Overriding fn changes state mutability from "view" to "payable".
