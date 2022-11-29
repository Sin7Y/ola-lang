contract C {
    event e(uint a, string b);
    fn f() public {
        emit e(2, "abc");
        emit e({b: "abc", a: 8});
    }
}
// ----
