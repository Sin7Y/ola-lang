contract test {
    fn a(u256 a, u256 b, u256 c)  -> (u256 r) { r = a * 100 + b * 10 + c * 1; }
    fn b()  -> (u256 r) { r = a({a: 1, b: 2, c: 3}); }
    fn c()  -> (u256 r) { r = a({b: 2, c: 3, a: 1}); }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// b() -> 123
// c() -> 123
