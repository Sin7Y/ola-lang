contract C {
    fn f()  {
        try this.f() {
        } catch Panic(bytes memory) {
        } catch Panic(u256) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 1271: (72-109): Expected `catch Panic(u256 ...) { ... }`.
// TypeError 6732: (110-139): This try statement already has a "Panic" catch clause.
