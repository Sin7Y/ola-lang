contract B {
    fn f(u256 x) mod(x) mod(2)  { }
    modifier mod(u256 a) { if (a > 0) _; }
}
// ----
