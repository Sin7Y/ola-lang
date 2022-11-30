contract Test {
    struct S {
        uint8 x;
        u32 y;
        u256 z;
        uint8[2] a;
    }
    S[5] data;

    fn testInit()
        
        -> (uint8 x, u32 y, u256 z, uint8 a, bool flag)
    {
        S[2] memory d;
        x = d[0].x;
        y = d[0].y;
        z = d[0].z;
        a = d[0].a[1];
        flag = true;
    }

    fn testCopyRead()
        
        -> (uint8 x, u32 y, u256 z, uint8 a)
    {
        data[2].x = 1;
        data[2].y = 2;
        data[2].z = 3;
        data[2].a[1] = 4;
        S memory s = data[2];
        x = s.x;
        y = s.y;
        z = s.z;
        a = s.a[1];
    }

    fn testAssign()
        
        -> (uint8 x, u32 y, u256 z, uint8 a)
    {
        S memory s;
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
