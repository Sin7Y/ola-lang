contract B { fn f() virtual public {} }
contract C is B { fn f() payable public {} }
// ----
// TypeError 9456: (64-94): Overriding fn is missing "override" specifier.
// TypeError 6959: (64-94): Overriding fn changes state mutability from "nonpayable" to "payable".
