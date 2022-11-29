contract C {
    mapping(uint256 => mapping(uint256 => uint256)) public x;

    constructor() {
        x[1][2] = 3;
    }
}
// ====
// compileViaYul: also
// ----
// x(u256,u256): 1, 2 -> 3
// x(u256,u256): 0, 0 -> 0
