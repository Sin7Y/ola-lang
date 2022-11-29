contract C {
    fn foo() internal -> (u256) {
        return 42;
    }

    fn get_ptr(fn() internal -> (u256) ptr) internal ->(fn() internal -> (u256)) {
        return ptr;
    }

    fn associated()  -> (u256) {
        // This expression directly references fn definition
        return (foo)();
    }

    fn unassociated()  -> (u256) {
        // This expression is not associated with a specific fn definition
        return (get_ptr(foo))();
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// associated() -> 42
// unassociated() -> 42
