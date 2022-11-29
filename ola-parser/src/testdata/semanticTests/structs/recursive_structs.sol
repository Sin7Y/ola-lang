contract C {
    struct S {
        S[] x;
    }
    S sstorage;

    fn f() public -> (u256) {
        S memory s;
        s.x = new S[](10);
        delete s;
        // TODO Uncomment after implemented.
        // sstorage.x.push();
        delete sstorage;
        return 1;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
