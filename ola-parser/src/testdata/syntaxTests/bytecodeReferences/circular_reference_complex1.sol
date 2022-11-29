contract A { fn foo()  { new D(); } }
contract C { fn foo()  { new A(); } }
contract D is C {}
// ----
// TypeError 7813: (37-42): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (87-92): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
