contract a { fn func() public {} }
contract c is a {
    fn g() public {
        uint var1 = fun();
    }
}
// ----
// DeclarationError 7576: (105-108): Undeclared identifier. Did you mean "func"?
