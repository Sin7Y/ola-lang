contract C {
    struct X {
        u256 x1;
        u256 x2;
    }
    struct S {
        u256 s1;
        u256[3] s2;
        X s3;
    }
    S s;

    constructor() {
        u256[3] memory s2;
        s2[1] = 9;
        s = S(1, s2, X(4, 5));
    }

    fn get()
        
        -> (u256 s1, u256[3] memory s2, u256 x1, u256 x2)
    {
        s1 = s.s1;
        s2 = s.s2;
        x1 = s.s3.x1;
        x2 = s.s3.x2;
    }
}
// ====
// compileViaYul: also
// ----
// get() -> 0x01, 0x00, 0x09, 0x00, 0x04, 0x05
