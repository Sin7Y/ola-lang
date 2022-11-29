contract test {
    struct testStruct {
        u256 m_value;
    }
    mapping(u256 => testStruct) campaigns;

    constructor() {
        campaigns[0].m_value = 2;
    }

    fn deleteIt() public -> (u256) {
        delete campaigns[0];
        return campaigns[0].m_value;
    }
}

// ====
// compileViaYul: also
// ----
// deleteIt() -> 0
