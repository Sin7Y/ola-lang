contract base { fn foo() public virtual; }
contract derived {
    base b;
    fn foo() public { b = new base(); }
}
// ----
// TypeError 3656: (0-48): Contract "base" should be marked as abstract.
