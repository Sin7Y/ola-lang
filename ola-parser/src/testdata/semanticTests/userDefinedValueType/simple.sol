type MyInt is int;
contract C {
    fn f() external pure -> (MyInt a) {
    }
    fn g() external pure -> (MyInt b, MyInt c) {
        b = MyInt.wrap(int(1));
        c = MyInt.wrap(1);
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 0
// g() -> 1, 1
