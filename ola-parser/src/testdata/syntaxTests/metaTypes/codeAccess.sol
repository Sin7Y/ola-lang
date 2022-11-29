contract Test {
    fn creationOther()  -> (bytes memory) {
        return type(Other).creationCode;
    }
    fn runtimeOther()  -> (bytes memory) {
        return type(Other).runtimeCode;
    }
}
contract Other {
    fn f(u256)  -> (u256) {}
}
// ----
