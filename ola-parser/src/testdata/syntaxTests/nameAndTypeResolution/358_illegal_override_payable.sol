contract B { fn f() payable virtual public {} }
contract C is B { fn f() public {} }
// ----
// TypeError 9456: (72-94): Overriding fn is missing "override" specifier.
// TypeError 6959: (72-94): Overriding fn changes state mutability from "payable" to "nonpayable".
