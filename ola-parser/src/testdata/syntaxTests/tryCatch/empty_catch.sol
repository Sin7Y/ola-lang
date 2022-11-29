contract C {
    fn f()  -> (u256, u256) {
        try this.f() {

        } catch () {

        }
    }
}
// ----
// ParserError 3546: (101-102): Expected type name
