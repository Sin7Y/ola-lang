abstract contract B {
    uint immutable x;

    constructor(fn() internal returns(uint) fp) {
        x = fp();
    }
}

contract C is B(C.f) {
    fn f() internal returns(uint) { return x = 2; }
}
// ----
// TypeError 1581: (200-201): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
// TypeError 1574: (109-110): Immutable state variable already initialized.
