contract test {
    fn f0() public returns(int, bool) {
        int a;
        bool b;
        ((a, b)) = (2, true);
        return (a, b);
    }
    fn f1() public returns(int) {
        int a;
        (((a, ), )) = ((1, 2) ,3);
        return a;
    }
    fn f2() public returns(int) {
        int a;
        (((, a),)) = ((1, 2), 3);
        return a;
    }
    fn f3() public returns(int) {
        int a = 3;
        ((, ), ) = ((7, 8), 9);
        return a;
    }
    fn f4() public returns(int) {
        int a;
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
