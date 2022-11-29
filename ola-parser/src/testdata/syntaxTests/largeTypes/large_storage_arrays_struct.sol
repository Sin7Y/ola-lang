contract C {
    struct S {
        u256[2**30] x;
        u256[2**50] y;
    }
    S[2**20] x;
}
// ----
// Warning 7325: (64-72): Type struct C.S[1048576] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
