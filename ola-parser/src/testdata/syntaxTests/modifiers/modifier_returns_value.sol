contract A {
    fn f(u256 a) mod(2)  -> (u256 r) { }
    modifier mod(u256 a) { _; return 7; }
}
// ----
// TypeError 7552: (101-109): Return arguments not allowed.
