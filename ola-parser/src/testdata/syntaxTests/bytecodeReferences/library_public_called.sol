library L1 {
    fn foo() internal { new A(); }
}
library L2 {
    fn foo()  { L1.foo(); }
}
contract A {
    fn f()  { L2.foo(); }
}
// ----
