abstract contract A {
    constructor(mapping(uint256 => uint256) storage m) {
        m[5] = 20;
    }
}

contract C is A {
    mapping(uint256 => uint256) public m;

    constructor() A(m) {}
}
// ====
// compileViaYul: also
// ----
// m(u256): 1 -> 0
// m(u256): 5 -> 20
