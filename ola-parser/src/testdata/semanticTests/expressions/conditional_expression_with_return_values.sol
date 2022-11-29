contract test {
    fn f(bool cond, uint v) public -> (uint a, uint b) {
        cond ? a = v : b = v;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(bool,u256): true, 20 -> 20, 0
// f(bool,u256): false, 20 -> 0, 20
