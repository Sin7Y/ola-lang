contract A {
	fn foo()  virtual -> (u256) {}
}
contract B is A {
	fn foo()  payable override virtual -> (u256) {}
}
// ----
// TypeError 6959: (86-153): Overriding fn changes state mutability from "nonpayable" to "payable".
