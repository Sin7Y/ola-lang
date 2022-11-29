contract test {
    fn f0()  ->(u32, bool) {
        u32 a;
        bool b;
        ((a, b)) = (2, true);
        return (a, b);
    }
    fn f1()  ->(u32) {
        u32 a;
        (((a, ), )) = ((1, 2) ,3);
        return a;
    }
    fn f2()  ->(u32) {
        u32 a;
        (((, a),)) = ((1, 2), 3);
        return a;
    }
    fn f3()  ->(u32) {
        u32 a = 3;
        ((, ), ) = ((7, 8), 9);
        return a;
    }
    fn f4()  ->(u32) {
        u32 a;
        (a, ) = (4, (8, 16, 32));
        return a;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f0() -> 2, true
// f1() -> 1
// f2() -> 2
// f3() -> 3
// f4() -> 4
