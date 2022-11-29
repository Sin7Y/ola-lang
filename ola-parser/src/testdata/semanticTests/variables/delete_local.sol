contract test {
    fn delLocal()  -> (u256 res){
        u256 v = 5;
        delete v;
        res = v;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// delLocal() -> 0
