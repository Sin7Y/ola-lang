contract C {
    fn f()  -> (u256, u256) {
        try this.f() -> (u256 a) {
            a = 1;
        } catch {

        }
    }
}
// ----
// TypeError 2800: (81-128): fn -> 2 values, but -> clause has 1 variables.
