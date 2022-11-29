contract A {
    fn f() external {}
    fn g(u256) external {}
}
contract B {
    fn f() external -> (u256) {}
    fn g(u256) external -> (u256) {}
}
contract C {
    fn test1() external ->(bytes4, bytes4, bytes4, bytes4) {
        return (A.f.selector, A.g.selector, B.f.selector, B.g.selector);
    }
    fn test2() external ->(bytes4, bytes4, bytes4, bytes4) {
        A a; B b;
        return (a.f.selector, a.g.selector, b.f.selector, b.g.selector);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test1() -> left(0x26121ff0), left(0xe420264a), left(0x26121ff0), left(0xe420264a)
// test2() -> left(0x26121ff0), left(0xe420264a), left(0x26121ff0), left(0xe420264a)
