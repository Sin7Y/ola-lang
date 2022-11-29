library L1 { fn foo() internal { L2.foo(); } }
library L2 { fn foo() internal { L1.foo(); } }
// ----
