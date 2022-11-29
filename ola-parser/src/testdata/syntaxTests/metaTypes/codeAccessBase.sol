contract Base {
    fn f()  -> (u256) {}
}
contract Test1 is Base {
    fn creation()  -> (bytes memory) {
        return type(Test1).creationCode;
    }
}
contract Test2 is Base {
    fn runtime()  -> (bytes memory) {
        return type(Test2).runtimeCode;
    }
}
contract Test3 is Base {
    fn creationBase()  -> (bytes memory) {
        return type(Base).creationCode;
    }
}
contract Test4 is Base {
    fn runtimeBase()  -> (bytes memory) {
        return type(Base).runtimeCode;
    }
}
// ----
// TypeError 7813: (166-190): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
// TypeError 7813: (300-323): Circular reference to contract bytecode either via "new" or "type(...).creationCode" / "type(...).runtimeCode".
