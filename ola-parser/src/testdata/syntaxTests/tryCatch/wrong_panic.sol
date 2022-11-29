contract C {
    fn f()  {
        try this.f() {
        } catch Panic() {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 1271: (72-97): Expected `catch Panic(u256 ...) { ... }`.
