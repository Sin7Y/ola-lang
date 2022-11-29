contract Lib {
    struct S {
        u256 a;
        u256 b;
    }
}


contract Test {
    fn f()  -> (u256 r) {
        Lib.S memory x = Lib.S({a: 2, b: 3});
        r = x.b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 3
