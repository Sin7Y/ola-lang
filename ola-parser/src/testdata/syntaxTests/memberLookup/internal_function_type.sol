contract C {
    fn () internal returns (uint) x;
    constructor() {
        C.x = g;
    }
    fn g() public pure returns (uint) {}
}
// ----
