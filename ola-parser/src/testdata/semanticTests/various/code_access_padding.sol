contract D {
    fn f()  -> (u256) {
        return 7;
    }
}


contract C {
    fn diff()  -> (u256 remainder) {
        bytes memory a = type(D).creationCode;
        bytes memory b = type(D).runtimeCode;
        assembly {
            remainder := mod(sub(b, a), 0x20)
        }
    }
}
// ====
// compileViaYul: also
// ----
// diff() -> 0 # This checks that the allocation fn pads to multiples of 32 bytes #
