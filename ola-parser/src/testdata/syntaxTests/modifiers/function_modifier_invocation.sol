contract B {
    fn f() mod1(2, true) mod2("0123456")   { }
    modifier mod1(u256 a, bool b) { if (b) _; }
    modifier mod2(bytes7 a) { while (a == "1234567") _; }
}
// ----
