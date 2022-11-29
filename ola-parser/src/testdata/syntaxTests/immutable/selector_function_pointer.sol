contract C {
    uint immutable x;
    constructor() {
        x = 3;
        readX().selector;
    }

    fn f() external view returns(uint)  {
        return x;
    }

    fn readX() public view returns(fn() external view returns(uint) _f) {
        _f = this.f;
    }
}
// ----
