pragma abicoder v2;
contract C {
    struct S { uint a; }
    event E(S);
    fn createEvent(uint x) public {
        emit E(S(x));
    }
}
// ====
// compileViaYul: also
// ----
// createEvent(u256): 42 ->
// ~ emit E((u256)): 0x2a
