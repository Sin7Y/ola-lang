contract A {}
contract C is A {
    modifier m() { _; }
}
contract D is A {
    fn f() C.m  {
    }
}
contract T is D, C {}
// ----
// TypeError 9428: (93-96): Can only use modifiers defined in the current contract or in base contracts.
