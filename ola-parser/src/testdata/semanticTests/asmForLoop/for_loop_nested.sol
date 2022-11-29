contract C {
    fn f(u256 x)  -> (u256 i) {
        assembly {
            for {} lt(i, 10) { i := add(i, 1) }
            {
                if eq(x, 0) { i := 2 break }
                for {} lt(x, 3) { i := 17 x := 9 } {
                    if eq(x, 1) { continue }
                    if eq(x, 2) { break }
                }
                if eq(x, 4) { i := 90 }
            }
        }
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 0 -> 2
// f(u256): 1 -> 18
// f(u256): 2 -> 10
// f(u256): 4 -> 91
