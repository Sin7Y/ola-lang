contract A {
    constructor(u256) {}
}
contract B {
    constructor(u256) {}
}
contract C {
    constructor(u256) {}
}
contract D {
    constructor(u256) {}
}
contract X is D, C, B, A {
    u256[] x;
    fn f(u256 _x) internal -> (u256) {
        x.push(_x);
    }
    fn g()  -> (u256[] memory) { return x; }
    constructor() A(f(1)) C(f(2)) B(f(3)) D(f(4)) {}
}
// ====
// compileViaYul: also
// ----
// g() -> 0x20, 4, 1, 3, 2, 4
