contract A {
    fn f()  {
        type(B).runtimeCode;
    }
}
contract B {
    fn f()  {
        type(A).runtimeCode;
    }
}
// ----
// TypeError 7813: (52-71): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (133-152): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
