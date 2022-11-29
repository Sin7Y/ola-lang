contract C {
    fn f()  -> (u256, u256) {
        try this.f() {
        }
    }
}
// ----
// ParserError 2314: (97-98): Expected 'catch' but got '}'
