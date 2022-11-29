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
        bytes memory c = type(D).creationCode;
        D d;
        assembly {
            d := create(0, add(c, 0x20), mload(c))
        }
        return d.f();
    }
}

// ====
// compileViaYul: also
// ----
// test() -> 7
// gas legacy: 102264
