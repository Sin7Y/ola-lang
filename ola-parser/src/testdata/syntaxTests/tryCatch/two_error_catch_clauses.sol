contract C {
    fn f()  -> (u256, u256) {
        try this.f() {

        } catch Error(string memory x) {
            x;
        } catch Error(string memory y) {
            y;
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 1036: (150-205): This try statement already has an "Error" catch clause.
