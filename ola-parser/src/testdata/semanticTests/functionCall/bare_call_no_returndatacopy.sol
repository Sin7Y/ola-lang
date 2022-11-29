contract C {
    fn f()  -> (bool) {
        (bool success, ) = address(1).call("");
        return success;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> true
