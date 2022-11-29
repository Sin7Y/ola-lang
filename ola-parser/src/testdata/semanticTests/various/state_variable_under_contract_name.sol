contract Scope {
    u256 stateVar = 42;

    fn getStateVar()  -> (u256 stateVar) {
        stateVar = Scope.stateVar;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getStateVar() -> 42
