contract C {
    bytes  initCode;

    constructor() {
        // This should catch problems, but lets also test the case the optimiser is buggy.
        assert(address(this).code.length == 0);
        initCode = address(this).code;
    }

    // To avoid dependency on exact length.
    fn f()  -> (bool) { return address(this).code.length > 400; }
    fn g()  -> (u256) { return address(0).code.length; }
    fn h()  -> (u256) { return address(1).code.length; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// constructor() ->
// gas irOptimized: 192317
// gas legacy: 240889
// gas legacyOptimized: 155314
// initCode() -> 0x20, 0
// f() -> true
// g() -> 0
// h() -> 0
