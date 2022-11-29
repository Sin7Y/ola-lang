contract C {
    fn f()  -> (u256, u256) {
        try this.f() -> (u256 a, u256 b) {
            a = 1;
            b = 2;
        } catch {

        }
    }
}
// ----
// Warning 6321: (46-50): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6321: (52-56): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
