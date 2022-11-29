interface IBase {
    fn foo() external view;
}

contract Base is IBase {
    fn foo()  virtual view {}
}

interface IExt is IBase {}

contract Ext is IExt, Base {}

contract Impl is Ext {
    fn foo()  {}
}
// ----
// TypeError 9456: (211-240): Overriding fn is missing "override" specifier.
// TypeError 4327: (211-240): fn needs to specify overridden contracts "Base" and "IBase".
