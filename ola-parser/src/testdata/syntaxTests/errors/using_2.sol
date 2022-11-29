error E(u256);
library L {
    fn f(u256) internal {}
}
contract C {
    using L for E;
    fn f()  {
        E.f();
    }
}
// ----
// TypeError 5172: (91-92): Name has to refer to a struct, enum or contract.
