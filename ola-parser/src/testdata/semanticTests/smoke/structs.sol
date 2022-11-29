pragma abicoder               v2;

contract C {
    struct S {
        uint a;
        uint b;
    }
    struct T {
        uint a;
        uint b;
        string s;
    }
    fn s() public returns (S memory) {
        return S(23, 42);
    }
    fn t() public returns (T memory) {
        return T(23, 42, "any");
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// s() -> 23, 42
// t() -> 0x20, 23, 42, 0x60, 3, "any"
