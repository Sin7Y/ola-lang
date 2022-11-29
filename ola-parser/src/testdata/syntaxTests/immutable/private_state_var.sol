contract B {
    uint immutable private x = f();

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
// TypeError 7733: (202-203): Immutable variables cannot be read before they are initialized.
