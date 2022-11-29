contract B {
    uint immutable x = 3;

    fn readX() internal view virtual returns(uint) {
        return x;
    }
}

contract C is B {
    constructor() {
        super.readX();
    }

    fn readX() internal pure override returns(uint) {
        return 1;
    }
}
// ----
