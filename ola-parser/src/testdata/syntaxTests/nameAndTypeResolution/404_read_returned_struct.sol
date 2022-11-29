pragma abicoder               v2;
contract A {
    struct T {
        int x;
        int y;
    }
    fn g() public returns (T memory) {
        return this.g();
    }
}
// ----
