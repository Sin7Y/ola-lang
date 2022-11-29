contract base { uint baseMember; struct BaseType { uint element; } }
contract derived is base {
    BaseType data;
    fn f() public { baseMember = 7; }
}
// ----
