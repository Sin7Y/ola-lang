contract A { fn f() public { new B(); } }
contract B { fn f() public { new C(); } }
contract C { fn f() public { new A(); } }
// ----
// TypeError 7813: (35-40): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (83-88): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (131-136): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
