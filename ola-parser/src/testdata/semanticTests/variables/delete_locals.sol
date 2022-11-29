contract test {
    fn delLocal()  -> (u256 res1, u256 res2){
        u256 v = 5;
        u256 w = 6;
        u256 x = 7;
        delete v;
        res1 = w;
        res2 = x;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// delLocal() -> 6, 7
