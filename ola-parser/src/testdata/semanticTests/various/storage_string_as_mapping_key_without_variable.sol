contract Test {
    mapping(string => u256) data;

    fn f()  -> (u256) {
        data["abc"] = 2;
        return data["abc"];
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 2
