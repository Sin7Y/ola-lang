pragma abicoder               v2;

contract C {
    struct T {
        uint a;
        uint b;
        string s;
    }
    bool[2][] flags;
    fn r() public returns (bool[3] memory) {
        return [true, false, true];
    }
    fn s() public returns (uint[2] memory, uint) {
        return ([uint(123), 456], 789);
    }
    fn u() public returns (T[2] memory) {
        return [T(23, 42, "any"), T(555, 666, "any")];
    }
    fn v() public returns (bool[2][] memory) {
        return flags;
    }
    fn w1() public returns (string[1] memory) {
        return ["any"];
    }
    fn w2() public returns (string[2] memory) {
        return ["any", "any"];
    }
    fn w3() public returns (string[3] memory) {
        return ["any", "any", "any"];
    }
    fn x() public returns (string[2] memory, string[3] memory) {
        return (["any", "any"], ["any", "any", "any"]);
    }
}
// ====
// compileViaYul: also
// ----
// r() -> true, false, true
// s() -> 123, 456, 789
// u() -> 0x20, 0x40, 0xE0, 23, 42, 0x60, 3, "any", 555, 666, 0x60, 3, "any"
// v() -> 0x20, 0
// w1() -> 0x20, 0x20, 3, "any"
// w2() -> 0x20, 0x40, 0x80, 3, "any", 3, "any"
// w3() -> 0x20, 0x60, 0xa0, 0xe0, 3, "any", 3, "any", 3, "any"
// x() -> 0x40, 0x0100, 0x40, 0x80, 3, "any", 3, "any", 0x60, 0xa0, 0xe0, 3, "any", 3, "any", 3, "any"
