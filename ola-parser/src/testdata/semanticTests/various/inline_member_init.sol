contract test {
    constructor() {
        m_b = 6;
        m_c = 8;
    }

    u256 m_a = 5;
    u256 m_b;
    u256 m_c = 7;

    fn get()  -> (u256 a, u256 b, u256 c) {
        a = m_a;
        b = m_b;
        c = m_c;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// get() -> 5, 6, 8
