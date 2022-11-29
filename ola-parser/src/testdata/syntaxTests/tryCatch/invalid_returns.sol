contract C {
    fn f()  -> (uint8, u256) {
        // Implicitly convertible, but not exactly the same type.
        try this.f() -> (u256, int x) {

        } catch {

        }
    }
}
// ----
// TypeError 6509: (157-161): Invalid type, expected uint8 but got u256.
// TypeError 6509: (163-168): Invalid type, expected u256 but got int256.
