contract C {
    fn f()  -> (u256, u256) {
        try this.f() {
        } catch Error2() {
        } catch abc() {
        }
    }
}
// ----
// TypeError 3542: (93-119): Invalid catch clause name. Expected either `catch (...)`, `catch Error(...)`, or `catch Panic(...)`.
// TypeError 3542: (120-143): Invalid catch clause name. Expected either `catch (...)`, `catch Error(...)`, or `catch Panic(...)`.
