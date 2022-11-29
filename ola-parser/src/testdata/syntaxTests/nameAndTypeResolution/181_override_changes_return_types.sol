contract base {
    fn f(uint a) public virtual returns (uint) { }
}
contract test is base {
    fn f(uint a) public override returns (uint8) { }
}
// ----
// TypeError 4822: (103-157): Overriding fn return types differ.
