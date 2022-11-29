contract C {
    mapping(uint=>uint)[] array;
    mapping(uint=>uint) map;
    fn f() public {
        array.pop();
    }
}
// ----
