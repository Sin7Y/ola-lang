interface IBase {
    fn foo() external view;
}

contract Base1 is IBase { fn foo()  virtual view {} }
contract Base2 is IBase { fn foo()  virtual view {} }

interface IExt1a is IBase {}
interface IExt1b is IBase {}
interface IExt2a is IBase {}
interface IExt2b is IBase {}

contract Ext1 is IExt1a, IExt1b, Base1 {}
contract Ext2 is IExt2a, IExt2b, Base2 {}

contract Impl is Ext1, Ext2 {
    fn foo()  override (IBase, Base1, Base2) {}
}
