contract BaseBase {
    u256 m_a;

    constructor(u256 a) {
        m_a = a;
    }

    fn g() public -> (u256 r) {
        return 2;
    }
}


contract Base is BaseBase(BaseBase.g()) {}


contract Derived is Base {
    fn getA() public -> (u256 r) {
        return m_a;
    }
}

// ====
// compileViaYul: also
// ----
// getA() -> 2
