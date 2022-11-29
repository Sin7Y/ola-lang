contract A {
    fn f() internal virtual returns(uint) { return 3; }
}

contract B {
    uint immutable x;

    constructor() {
        x = xInit();
    }

    fn xInit() internal virtual returns(uint) {
        return f();
    }

    fn f() internal virtual returns(uint) { return 3; }
}

contract C is A, B {
    fn xInit() internal override returns(uint) {
        return super.xInit();
    }

    fn f() internal override(A, B) returns(uint) {
        return x;
    }
}
// ----
// TypeError 7733: (493-494): Immutable variables cannot be read before they are initialized.
