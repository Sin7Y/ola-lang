contract buggystruct {
    Buggy  bug;

    struct Buggy {
        u256 first;
        u256 second;
        u256 third;
        string last;
    }

    constructor() {
        bug = Buggy(10, 20, 30, "asdfghjkl");
    }

    fn getFirst()  -> (u256) {
        return bug.first;
    }

    fn getSecond()  -> (u256) {
        return bug.second;
    }

    fn getThird()  -> (u256) {
        return bug.third;
    }

    fn getLast()  -> (string memory) {
        return bug.last;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// getFirst() -> 0x0a
// getSecond() -> 0x14
// getThird() -> 0x1e
// getLast() -> 0x20, 0x09, "asdfghjkl"
