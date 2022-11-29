contract C {
    fn f()  -> (u256 i) {
        assembly {
            for {} lt(i, 10) { i := add(i, 1) }
            {
                if eq(i, 6) { break }
                i := add(i, 1)
            }
        }
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 6
