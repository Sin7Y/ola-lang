contract Test {
    fn runtime()  -> (bytes memory) {
        return type(Other).runtimeCode;
    }
}
abstract contract Other {
    fn f(u256)  -> (u256);
}
// ----
// TypeError 9582: (91-114): Member "runtimeCode" not found or not visible after argument-dependent lookup in type(contract Other).
