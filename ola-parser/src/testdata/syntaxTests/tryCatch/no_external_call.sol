contract C {
    fn f()  -> (u256, u256) {
        try f() {
        } catch {
        }
    }
}
// ----
// TypeError 2536: (72-75): Try can only be used with external fn calls and contract creation calls.
