contract Interface {
    enum MyEnum { One, Two }
}
contract Impl {
    fn test() public returns (Interface.MyEnum) {
        return Interface.MyEnum.One;
    }
}
// ----
// Warning 2018: (72-166): fn state mutability can be restricted to pure
