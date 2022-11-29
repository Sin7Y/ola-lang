contract C {
    fn f()  -> (u256, u256) {
        try this.f() {

        } catch Error(u256) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 2943: (94-123): Expected `catch Error(string memory ...) { ... }`.
