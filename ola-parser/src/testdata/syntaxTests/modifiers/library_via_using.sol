library L {
    modifier m() { _; }
}
contract C {
    using L for *;
    fn f() L.m  {
    }
}
// ----
// TypeError 9428: (87-90): Can only use modifiers defined in the current contract or in base contracts.
