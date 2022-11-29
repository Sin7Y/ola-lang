contract C {
    fn f(bool b) 
    {
        if ‬(b) { return; }
    }
}
// ----
// ParserError 2314: (65-66): Expected '(' but got 'ILLEGAL'
