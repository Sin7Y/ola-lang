contract C {
    fn f()  {
        try this.f() {
        } catch Error(string memory) {
        } catch Panic(u256) {
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
