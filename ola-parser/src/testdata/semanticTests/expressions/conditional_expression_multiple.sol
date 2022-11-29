contract test {
    fn f(u256 x)  ->(u256 d) {
        return x > 100 ?
                    x > 1000 ? 1000 : 100
                    :
                    x > 50 ? 50 : 10;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 1001 -> 1000
// f(u256): 500 -> 100
// f(u256): 80 -> 50
// f(u256): 40 -> 10
