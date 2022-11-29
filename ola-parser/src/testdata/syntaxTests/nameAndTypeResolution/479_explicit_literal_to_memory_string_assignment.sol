contract C {
    fn f() pure public {
        string memory x = "abc";
        x;
    }
}
// ----
