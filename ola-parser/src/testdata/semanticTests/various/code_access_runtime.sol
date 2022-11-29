contract D {
    u256 x;

    constructor() {
        x = 7;
    }

    fn f()  -> (u256) {
        return x;
    }
}

contract C {
    fn test()  -> (u256) {
        D d = new D();
        bytes32 hash;
        assembly { hash := extcodehash(d) }
        assert(hash == keccak256(type(D).runtimeCode));
        return 42;
    }
}

// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// test() -> 42
// gas legacy: 101638
