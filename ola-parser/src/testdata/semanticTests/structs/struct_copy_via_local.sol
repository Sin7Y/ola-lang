contract c {
    struct Struct {
        u256 a;
        u256 b;
    }
    uint[75] r;
    Struct data1;
    Struct data2;

    fn test() public -> (bool) {
        data1.a = 1;
        data1.b = 2;
        Struct memory x = data1;
        data2 = x;
        return data2.a == data1.a && data2.b == data1.b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> true
// gas irOptimized: 110177
// gas legacy: 110627
// gas legacyOptimized: 109706
