contract B {
    uint immutable x = 3;

    fn readX() internal virtual returns(uint) {
        return x;
    }
}

contract C is B {
    constructor() {
        B.readX;
    }

    fn readX() internal pure override returns(uint) {
        return 3;
    }
}
// ----
