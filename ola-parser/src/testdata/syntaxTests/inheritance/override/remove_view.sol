contract B { fn f() virtual  {} }
contract C is B { fn f()  {} }
// ----
// TypeError 9456: (69-91): Overriding fn is missing "override" specifier.
// TypeError 6959: (69-91): Overriding fn changes state mutability from "view" to "nonpayable".
