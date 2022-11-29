// This tests skipping the extcodesize check.

contract T {
    constructor() { this.f(); }
    fn f() external {}
}
contract U {
    constructor() { this.f(); }
    fn f() external -> (uint) {}
}

contract C {
    fn f(uint c) external -> (uint) {
        if (c == 0) new T();
        else if (c == 1) new U();
        return 1 + c;
    }
}

// ====
// EVMVersion: >=byzantium
// compileViaYul: also
// ----
// f(u256): 0 -> FAILURE
// f(u256): 1 -> FAILURE
// f(u256): 2 -> 3
