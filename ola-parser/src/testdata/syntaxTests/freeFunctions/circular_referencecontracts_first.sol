// Checks that error is triggered no matter which order
contract D {
    fn f()  {
        l();
    }
}
contract C {
    constructor() { new D(); }
}
fn l() {
    s();
}
fn s() {
    new C();
}
// ----
// TypeError 7813: (207-212): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (149-154): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
