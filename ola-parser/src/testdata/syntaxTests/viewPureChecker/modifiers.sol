contract D {
    u256 x;
    modifier purem(u256) { _; }
    modifier viewm(u256) { u256 a = x; _; a; }
    modifier nonpayablem(u256) { x = 2; _; }
}
contract C is D {
    fn f() purem(0)   {}
    fn g() viewm(0) view  {}
    fn h() nonpayablem(0)  {}
    fn i() purem(x) view  {}
    fn j() viewm(x) view  {}
    fn k() nonpayablem(x)  {}
    fn l() purem(x = 2)  {}
    fn m() viewm(x = 2)  {}
    fn n() nonpayablem(x = 2)  {}
}
// ----
