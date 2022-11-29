contract D { fn f() pure public {} }
contract C is D {
    fn f(uint) pure public {}
}
// ----
