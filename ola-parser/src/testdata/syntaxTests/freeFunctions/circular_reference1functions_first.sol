// Checks that error is triggered no matter which order
fn l() {
    s();
}
fn s() {
	new C();
}
contract D {
	fn f()  {
		l();
	}
}
contract C {
	constructor() { new D(); }
}
// ----
// TypeError 7813: (98-103): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (187-192): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
