interface IBase {
    fn foo() external view;
}

contract Base is IBase {
    fn foo()  virtual view {}
}

interface IExt is IBase {}

contract Ext is IExt, Base {}

contract T { fn foo()  virtual view {} }

contract Impl is Ext, T {
    fn foo()  override(IBase, Base, T) {}
}
