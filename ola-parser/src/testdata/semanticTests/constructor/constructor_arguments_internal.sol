contract Helper {
    bytes3 name;
    bool flag;

    constructor(bytes3 x, bool f) {
        name = x;
        flag = f;
    }

    fn getName()  -> (bytes3 ret) {
        return name;
    }

    fn getFlag()  -> (bool ret) {
        return flag;
    }
}


contract Main {
    Helper h;

    constructor() {
        h = new Helper("abc", true);
    }

    fn getFlag()  -> (bool ret) {
        return h.getFlag();
    }

    fn getName()  -> (bytes3 ret) {
        return h.getName();
    }
}

// ====
// compileViaYul: also
// ----
// getFlag() -> true
// getName() -> "abc"
