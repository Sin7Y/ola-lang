library L1 {
    fn foo()  { L2.foo(); }

}
library L2 {
    fn foo() internal { type(L1).creationCode; }
}
// ----
// TypeError 7813: (99-120): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
