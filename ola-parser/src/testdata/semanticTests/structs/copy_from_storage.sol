pragma abicoder v2;
// Example from https://github.com/ethereum/solidity/issues/12558
struct S {
    u256 x;
}

contract C {
    S sStorage;
    constructor() {
        sStorage.x = 13;
    }

    fn f() external -> (S[] memory) {
        S[] memory sMemory = new S[](1);

        sMemory[0] = sStorage;

        return sMemory;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 0x20, 1, 13
