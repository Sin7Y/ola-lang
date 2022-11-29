abstract contract base { fn foo() public virtual; }
contract derived is base { fn foo() public virtual override {} }
contract wrong is derived { fn foo() public virtual override; }
// ----
// TypeError 4593: (157-196): Overriding an implemented fn with an unimplemented fn is not allowed.
