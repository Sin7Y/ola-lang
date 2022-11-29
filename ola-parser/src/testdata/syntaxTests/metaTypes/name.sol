contract Test {
    fn f()  -> (string memory) {
        return type(Test).name;
    }
}
// ----
