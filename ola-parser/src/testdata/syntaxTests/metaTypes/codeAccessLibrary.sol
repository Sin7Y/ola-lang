contract Test {
    fn creationOther()  -> (bytes memory) {
        return type(Library).creationCode;
    }
    fn runtime()  -> (bytes memory) {
        return type(Library).runtimeCode;
    }
}
contract Library {
    fn f(u256)  -> (u256) {}
}
// ----
