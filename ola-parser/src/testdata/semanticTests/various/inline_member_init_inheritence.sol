contract Base {
    constructor() {}

    u256 m_base = 5;

    fn getBMember()  -> (u256 i) {
        return m_base;
    }
}


contract Derived is Base {
    constructor() {}

    u256 m_derived = 6;

    fn getDMember()  -> (u256 i) {
        return m_derived;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getBMember() -> 5
// getDMember() -> 6
