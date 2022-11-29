pragma abicoder               v2;


// Checks that address types are properly cleaned before they are compared.
contract C {
    fn f(address a) public -> (u256) {
        if (a != 0x1234567890123456789012345678901234567890) return 1;
        return 0;
    }

    fn g(address payable a) public -> (u256) {
        if (a != 0x1234567890123456789012345678901234567890) return 1;
        return 0;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(address): 0xffff1234567890123456789012345678901234567890 -> FAILURE # We input longer data on purpose.#
// g(address): 0xffff1234567890123456789012345678901234567890 -> FAILURE
