contract test {
    mapping(uint=>uint) map;
    fn fun() public view {
        mapping(uint=>uint) storage a = map;
        mapping(uint=>uint) storage b = map;
        b = a;
        (b) = a;
        (b, b) = (a, a);
    }
}
// ----
