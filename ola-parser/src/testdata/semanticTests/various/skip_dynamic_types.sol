// The EVM cannot provide access to dynamically-sized return values, so we have to skip them.
contract C {
    fn f()  -> (u256, u256[] memory, u256) {
        return (7, new u256[](2), 8);
    }

    fn g()  -> (u256, u256) {
        // Previous implementation "moved" b to the second place and did not skip.
        (u256 a, , u256 b) = this.f();
        return (a, b);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 7, 8
