contract base {
    enum a { X }
    fn f(a) public { }
}
contract test is base {
    fn f(uint8 a) public { }
}
// ----
// TypeError 9914: (37-61): fn overload clash during conversion to external types for arguments.
