contract C {
    struct R { u256[10][10] y; }
    struct S { u256 a; u256 b; R d; u256[20][20][2999999999999999999999999990] c; }
    fn f()  {
        C.S memory y;
        C.S[10] memory z;
        y.a < 2;
        z; y;
    }
}
// ----
// TypeError 1534: (169-181): Type too large for memory.
