contract D {
    u256 x;
    modifier viewm(u256) { u256 a = x; _; a; }
    modifier nonpayablem(u256) { x = 2; _; }
}
contract C is D {
    fn f() viewm(0)   {}
    fn g() nonpayablem(0) view  {}
}
// ----
// TypeError 2527: (154-162): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (195-209): fn cannot be declared as view because this expression (potentially) modifies the state.
