contract B { fn f() virtual  {} }
contract C is B { fn f() override  {} }
// ----
