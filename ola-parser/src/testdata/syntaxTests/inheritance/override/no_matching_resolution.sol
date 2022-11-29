contract A {
    fn f() virtual internal {}
}
contract B is A {
    fn f() virtual override internal {}
    fn h() pure internal { f; }
}
contract C is B {
    fn f() override internal {}
    fn i() pure internal { f; }
}
// ----
