contract C {
    modifier m() { _; }
}
contract D {
    fn f() C.m  {
    }
}
// ----
// TypeError 9428: (69-72): Can only use modifiers defined in the current contract or in base contracts.
