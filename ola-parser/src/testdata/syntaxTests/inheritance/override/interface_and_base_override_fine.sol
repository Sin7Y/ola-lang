interface IBase {
    fn foo() external view;
}

contract Base is IBase {
    fn foo()  virtual view {}
}

interface IExt is IBase {}

contract Ext is IExt, Base {}

contract Impl is Ext {
    fn foo()  override (IBase, Base) {}
}
// ----
