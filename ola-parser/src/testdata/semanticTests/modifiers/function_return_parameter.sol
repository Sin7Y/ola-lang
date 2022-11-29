// The IR of this contract used to throw
contract B {
    fn f(uint8 a) mod1(a, true) mod2(r)   -> (bytes7 r) { }
    modifier mod1(u256 a, bool b) { if (b) _; }
    modifier mod2(bytes7 a) { while (a == "1234567") _; }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(uint8): 5 -> 0x00
