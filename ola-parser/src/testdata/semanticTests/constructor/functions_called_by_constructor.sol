contract Test {
    bytes3 name;
    bool flag;

    constructor() {
        setName("abc");
    }

    fn getName()  -> (bytes3 ret) {
        return name;
    }

    fn setName(bytes3 _name) private {
        name = _name;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getName() -> "abc"
