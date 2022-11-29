contract test {
    fn f(u256 k)  -> (u256) {
        return k;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 9 -> 9
