contract C {
    modifier m() { _; }
}
contract D is C {
    fn f() C.m  {
    }
}
// ----
