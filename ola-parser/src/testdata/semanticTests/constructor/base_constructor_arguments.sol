contract BaseBase {
    u256 m_a;

    constructor(u256 a) {
        m_a = a;
    }
}


contract Base is BaseBase(7) {
    constructor() {
        m_a *= m_a;
    }
}


contract Derived is Base {
    fn getA() public -> (u256 r) {
        return m_a;
    }
}

// ====
// compileViaYul: also
// ----
// getA() -> 49
