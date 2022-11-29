contract C {
    fn f()  {
        try this.f() {
        } catch Panic(bytes memory) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 1271: (72-109): Expected `catch Panic(u256 ...) { ... }`.
