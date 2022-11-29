contract B {
    uint immutable private x;

    constructor() {
    }

    fn f() internal view virtual returns(uint) { return 1; }
    fn readX() internal view returns(uint) { return x; }
}

contract C is B {
    uint immutable y;
    constructor() {
        y = 3;
    }
    fn f() internal view override returns(uint) { return readX(); }

}
// ----
// TypeError 2658: (0-202): Construction control flow ends without initializing all immutable state variables.
// TypeError 2658: (204-361): Construction control flow ends without initializing all immutable state variables.
