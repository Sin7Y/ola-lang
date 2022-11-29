contract C {
    fn f()  -> (u256, u256) {
        try this.f() {

        } catch (u256) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 6231: (94-118): Expected `catch (bytes memory ...) { ... }` or `catch { ... }`.
