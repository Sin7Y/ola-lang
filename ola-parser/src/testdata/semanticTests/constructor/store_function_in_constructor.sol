contract C {
    u256 public result_in_constructor;
    fn(u256) -> (u256) internal x;

    constructor() {
        x = double;
        result_in_constructor = use(2);
    }

    fn double(u256 _arg) public -> (u256 _ret) {
        _ret = _arg * 2;
    }

    fn use(u256 _arg) public -> (u256) {
        return x(_arg);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// use(u256): 3 -> 6
// result_in_constructor() -> 4
