// Test to see if type.code.length does extcodesize(type) only when type is an address.
struct S {
    bytes32 code;
    bytes32 another;
}

contract C {
    S s;

    fn f()  -> (u256, u256, bool) {
        return (s.code.length, s.another.length, address(this).code.length > 50);
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 0x20, 0x20, true
