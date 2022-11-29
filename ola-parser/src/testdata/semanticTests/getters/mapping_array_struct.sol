contract C {
    struct Y {
        uint256 a;
        uint256 b;
    }
    mapping(u256 => Y[]) public m;
    mapping(u256 => Y[3]) public n;

    constructor() {
        m[1].push().a = 1;
        m[1][0].b = 2;
        m[1].push().a = 3;
        m[1][1].b = 4;
        n[1][0].a = 7;
        n[1][0].b = 8;
        n[1][1].a = 9;
        n[1][1].b = 10;
    }
}
// ====
// compileViaYul: also
// ----
// m(u256,u256): 0, 0 -> FAILURE
// m(u256,u256): 1, 0 -> 1, 2
// m(u256,u256): 1, 1 -> 3, 4
// m(u256,u256): 1, 2 -> FAILURE
// n(u256,u256): 0, 0 -> 0x00, 0x00
// n(u256,u256): 1, 0 -> 7, 8
// n(u256,u256): 1, 1 -> 9, 0x0a
// n(u256,u256): 1, 2 -> 0x00, 0x00
