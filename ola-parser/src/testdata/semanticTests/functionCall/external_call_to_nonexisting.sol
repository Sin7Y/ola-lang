// This tests skipping the extcodesize check.

interface I {
    fn a() external pure;
    fn b() external;
    fn c() external payable;
    fn x() external -> (uint);
    fn y() external -> (string memory);
}
contract C {
    I i = I(address(0xcafecafe));
    constructor() payable {}
    fn f(uint c) external -> (uint) {
        if (c == 0) i.a();
        else if (c == 1) i.b();
        else if (c == 2) i.c();
        else if (c == 3) i.c{value: 1}();
        else if (c == 4) i.x();
        else if (c == 5) i.y();
        return 1 + c;
    }
}

// ====
// compileViaYul: also
// ----
// constructor(), 1 ether ->
// gas irOptimized: 303935
// gas legacy: 464030
// gas legacyOptimized: 304049
// f(u256): 0 -> FAILURE
// f(u256): 1 -> FAILURE
// f(u256): 2 -> FAILURE
// f(u256): 3 -> FAILURE
// f(u256): 4 -> FAILURE
// f(u256): 5 -> FAILURE
// f(u256): 6 -> 7
