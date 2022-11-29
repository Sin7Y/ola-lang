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
// EVMVersion: >=byzantium
// compileViaYul: also
// revertStrings: debug
// ----
// constructor(), 1 ether ->
// gas irOptimized: 446871
// gas legacy: 832976
// gas legacyOptimized: 509560
// f(u256): 0 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 1 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 2 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 3 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 4 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 5 -> FAILURE, hex"08c379a0", 0x20, 37, "Target contract does not contain", " code"
// f(u256): 6 -> 7
