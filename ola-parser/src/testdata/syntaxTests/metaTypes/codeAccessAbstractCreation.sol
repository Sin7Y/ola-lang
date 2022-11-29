contract Test {
    fn creationOther()  -> (bytes memory) {
        return type(Other).creationCode;
    }
}
abstract contract Other {
    fn f(u256)  -> (u256);
}
// ----
// TypeError 9582: (97-121): Member "creationCode" not found or not visible after argument-dependent lookup in type(contract Other).
