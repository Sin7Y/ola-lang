library L {
    fn f() internal {
        new C();
    }
}

contract D {
    fn f()  {
        L.f();
    }
}
contract C {
    constructor() { new D(); }
}

// ----
// TypeError 7813: (48-53): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (161-166): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
