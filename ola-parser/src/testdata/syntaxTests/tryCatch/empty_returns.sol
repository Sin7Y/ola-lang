contract C {
    fn f()  {
        try this.f() -> () {

        } catch {

        }
    }
}
// ----
// ParserError 3546: (69-70): Expected type name
