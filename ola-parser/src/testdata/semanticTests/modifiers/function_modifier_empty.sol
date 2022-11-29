abstract contract A {
    fn f()  mod -> (bool r) {
        return true;
    }

    modifier mod virtual;
}


contract C is A {
    modifier mod override {
        if (false) _;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> false
