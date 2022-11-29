contract c {
    uint[] data;
    fn test() public {
        data.push(7);
        data.pop();
    }
}
// ====
// compileViaYul: also
// ----
// test() ->
// storageEmpty -> 1
