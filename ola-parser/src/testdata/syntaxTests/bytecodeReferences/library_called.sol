library L1 {
    fn foo() internal { new A(); }
}
library L2 {
    fn foo() internal { L1.foo(); }
}
contract A {
    fn f()  { L2.foo(); }
}
// ----
// TypeError 7813: (43-48): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
