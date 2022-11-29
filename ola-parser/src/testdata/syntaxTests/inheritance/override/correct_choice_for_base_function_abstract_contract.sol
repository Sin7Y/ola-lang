abstract contract IBase {
    fn foo() external view virtual;
}

contract Base is IBase {
    fn foo()  virtual override view {}
}

abstract contract IExt is IBase {}

contract Ext is IExt, Base {}

contract T { fn foo()  virtual view {} }

contract Impl is Ext, T {
    fn foo()  override(IBase, Base, T) {}
}
