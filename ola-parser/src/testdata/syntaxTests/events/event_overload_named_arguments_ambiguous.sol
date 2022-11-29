contract C {
    event e(uint u, string s);
    event e(string s, uint u);

    fn call() public {
        emit e({u: 2, s: "abc"});
    }
}
// ----
// TypeError 4487: (118-119): No unique declaration found after argument-dependent lookup.
