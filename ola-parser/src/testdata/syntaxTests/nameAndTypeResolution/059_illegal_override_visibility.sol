contract B { fn f() virtual internal {} }
contract C is B { fn f() public {} }
// ----
// TypeError 9456: (66-88): Overriding fn is missing "override" specifier.
// TypeError 9098: (66-88): Overriding fn visibility differs.
