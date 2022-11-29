contract C {
    fn f(int a, int b)  -> (int) {
        return a % b;
    }
    fn g(bool _check)  -> (int) {
        int x = type(int).min;
        if (_check) {
            return x / -1;
        } else {
            unchecked { return x / -1; }
        }
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(int256,int256): 7, 5 -> 2
// f(int256,int256): 7, -5 -> 2
// f(int256,int256): -7, 5 -> -2
// f(int256,int256): -7, 5 -> -2
// f(int256,int256): -5, -5 -> 0
// g(bool): true -> FAILURE, hex"4e487b71", 0x11
// g(bool): false -> -57896044618658097711785492504343953926634992332820282019728792003956564819968
