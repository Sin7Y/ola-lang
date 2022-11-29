contract Scope {
    fn getStateVar() view  -> (u256 stateVar) {
        stateVar = Scope.stateVar; // should fail.
    }
}
// ----
// TypeError 9582: (101-115): Member "stateVar" not found or not visible after argument-dependent lookup in type(contract Scope).
