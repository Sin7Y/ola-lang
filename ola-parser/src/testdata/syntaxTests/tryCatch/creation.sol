contract D {
}
contract C {
    fn f()  {
        try new D() {
        } catch (bytes memory x) {
            x;
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
