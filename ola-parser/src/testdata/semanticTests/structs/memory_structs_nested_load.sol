contract Test {
    struct S {
        u32 x;
        u32 y;
        u256 z;
    }
    struct X {
        u32 x;
        S s;
        u32[2] a;
    }
    X m_x;

    fn load()

        -> (
            u256 a,
            u256 x,
            u256 y,
            u256 z,
            u256 a1,
            u256 a2
        )
    {
        m_x.x = 1;
        m_x.s.x = 2;
        m_x.s.y = 3;
        m_x.s.z = 4;
        m_x.a[0] = 5;
        m_x.a[1] = 6;
        X  d = m_x;
        a = d.x;
        x = d.s.x;
        y = d.s.y;
        z = d.s.z;
        a1 = d.a[0];
        a2 = d.a[1];
    }

    fn store()

        -> (
            u256 a,
            u256 x,
            u256 y,
            u256 z,
            u256 a1,
            u256 a2
        )
    {
        X  d;
        d.x = 1;
        d.s.x = 2;
        d.s.y = 3;
        d.s.z = 4;
        d.a[0] = 5;
        d.a[1] = 6;
        m_x = d;
        a = m_x.x;
        x = m_x.s.x;
        y = m_x.s.y;
        z = m_x.s.z;
        a1 = m_x.a[0];
        a2 = m_x.a[1];
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// load() -> 0x01, 0x02, 0x03, 0x04, 0x05, 0x06
// gas irOptimized: 111425
// gas legacy: 112999
// gas legacyOptimized: 110881
// store() -> 0x01, 0x02, 0x03, 0x04, 0x05, 0x06
