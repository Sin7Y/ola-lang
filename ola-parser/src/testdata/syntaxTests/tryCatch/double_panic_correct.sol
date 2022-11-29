contract C {
    fn f()  {
        try this.f() {
        } catch Panic(u256) {
        } catch Panic(u256) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 6732: (102-131): This try statement already has a "Panic" catch clause.
