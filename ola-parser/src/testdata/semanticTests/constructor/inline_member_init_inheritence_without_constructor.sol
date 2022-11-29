contract Base {
    u256 m_base = 5;

    fn getBMember() public -> (u256 i) {
        return m_base;
    }
}


contract Derived is Base {
    u256 m_derived = 6;

    fn getDMember() public -> (u256 i) {
        return m_derived;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getBMember() -> 5
// getDMember() -> 6
