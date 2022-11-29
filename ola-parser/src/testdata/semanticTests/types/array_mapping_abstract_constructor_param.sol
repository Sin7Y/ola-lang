abstract contract A {
    constructor(mapping(uint256 => uint256)[] storage m) {
        m.push();
        m[0][1] = 2;
    }
}

contract C is A {
    mapping(uint256 => mapping(uint256 => uint256)[]) public m;

    constructor() A(m[1]) {}
}
// ====
// compileViaYul: also
// ----
// m(u256,u256,u256): 0, 0, 0 -> FAILURE
// m(u256,u256,u256): 1, 0, 1 -> 2
// m(u256,u256,u256): 1, 0, 5 -> 0
