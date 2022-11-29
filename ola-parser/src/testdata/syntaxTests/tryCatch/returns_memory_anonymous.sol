contract C {
    fn f()  -> (u256[] memory, u256) {
        try this.f() -> (u256[] memory, u256) {

        } catch {

        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// Warning 6321: (46-59): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6321: (61-65): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
