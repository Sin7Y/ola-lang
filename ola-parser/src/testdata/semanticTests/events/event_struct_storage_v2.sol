pragma abicoder v2;
contract C {
    struct S { uint a; }
    event E(S);
    S s;
    fn createEvent(uint x) public {
        s.a = x;
        emit E(s);
    }
}
// ====
// compileViaYul: also
// ----
// createEvent(u256): 42 ->
// ~ emit E((u256)): 0x2a
