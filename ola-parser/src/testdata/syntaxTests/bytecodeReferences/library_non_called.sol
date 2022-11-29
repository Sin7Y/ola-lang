library L1 {
    fn foo() internal { new A(); }
}
library L2 {
    fn foo() internal { L1.foo(); }
}
contract A {
    fn f()  { type(L2).creationCode; }
}
// ----
// Warning 6133: (157-178): Statement has no effect.
