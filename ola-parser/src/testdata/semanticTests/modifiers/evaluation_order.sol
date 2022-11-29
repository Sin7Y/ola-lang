contract A { constructor(u256) {} }
contract B { constructor(u256) {} }
contract C { constructor(u256) {} }

contract D is A, B, C {
    u256[] x;
    constructor() m2(f(1)) B(f(2)) m1(f(3)) C(f(4)) m3(f(5)) A(f(6)) {
        f(7);
    }

    fn query()  -> (u256[] memory) { return x; }

    modifier m1(u256) { _; }
    modifier m2(u256) { _; }
    modifier m3(u256) { _; }

    fn f(u256 y) internal -> (u256) { x.push(y); return 0; }
}
// ====
// compileViaYul: also
// ----
// query() -> 0x20, 7, 4, 2, 6, 1, 3, 5, 7
