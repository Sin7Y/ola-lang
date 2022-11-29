contract C {
    fn f()  -> (u256, u256) {
        try this.f() {

        } catch {
        } catch (bytes memory y) {
            y;
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 5320: (112-161): This try statement already has a low-level catch clause.
