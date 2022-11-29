contract test {
    fn f()  ->(u256 r) {
        u256 i = 0;
        do
        {
            if (i > 0) return 0;
            i++;
            continue;
        } while (false);
        return 42;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 42
