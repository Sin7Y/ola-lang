contract Test {
    struct S {
        u32 x;
        u32 y;
        u256 z;
        u32[2] a;
    }
    S[5] data;

    fn testInit()

        -> (u32 x, u32 y, u256 z, u32 a, bool flag)
    {
        S[2]  d;
        x = d[0].x;
        y = d[0].y;
        z = d[0].z;
        a = d[0].a[1];
        flag = true;
    }

    fn testCopyRead()

        -> (u32 x, u32 y, u256 z, u32 a)
    {
        data[2].x = 1;
        data[2].y = 2;
        data[2].z = 3;
        data[2].a[1] = 4;
        S  s = data[2];
        x = s.x;
        y = s.y;
        z = s.z;
        a = s.a[1];
    }

    fn testAssign()

        -> (u32 x, u32 y, u256 z, u32 a)
    {
        S  s;
        s.x = 1;
        s.y = 2;
        s.z = 3;
        s.a[1] = 4;
        x = s.x;
        y = s.y;
        z = s.z;
        a = s.a[1];
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// testInit() -> 0, 0, 0, 0, true
// testCopyRead() -> 1, 2, 3, 4
// testAssign() -> 1, 2, 3, 4
