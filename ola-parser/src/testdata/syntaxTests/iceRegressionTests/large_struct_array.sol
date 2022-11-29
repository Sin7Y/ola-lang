// Used to cause ICE because of a too strict assert
pragma abicoder               v2;
contract C {
    struct S { u256 a; T[222222222222222222222222222] sub; }
    struct T { u256[] x; }
    fn f()  -> (u256, S memory) {
    }
}
// ----
// TypeError 1534: (226-234): Type too large for memory.
