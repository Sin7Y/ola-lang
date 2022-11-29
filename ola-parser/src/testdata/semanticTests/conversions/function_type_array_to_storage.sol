contract C {
    fn () external returns(uint)[1] externalDefaultArray;
    fn () external view returns(uint)[1] externalViewArray;
    fn () external pure returns(uint)[1] externalPureArray;

    fn () internal returns(uint)[1] internalDefaultArray;
    fn () internal view returns(uint)[1] internalViewArray;
    fn () internal pure returns(uint)[1] internalPureArray;

    fn externalDefault() external returns(uint) { return 11; }
    fn externalView() external view returns(uint) { return 12; }
    fn externalPure() external pure returns(uint) { return 13; }

    fn internalDefault() internal returns(uint) { return 21; }
    fn internalView() internal view returns(uint) { return 22; }
    fn internalPure() internal pure returns(uint) { return 23; }

    fn testViewToDefault() public returns (uint, uint) {
        externalDefaultArray = [this.externalView];
        internalDefaultArray = [internalView];

        return (externalDefaultArray[0](), internalDefaultArray[0]());
    }

    fn testPureToDefault() public returns (uint, uint) {
        externalDefaultArray = [this.externalPure];
        internalDefaultArray = [internalPure];

        return (externalDefaultArray[0](), internalDefaultArray[0]());
    }

    fn testPureToView() public returns (uint, uint) {
        externalViewArray = [this.externalPure];
        internalViewArray = [internalPure];

        return (externalViewArray[0](), internalViewArray[0]());
    }
}
// ====
// compileViaYul: also
// ----
// testViewToDefault() -> 12, 22
// testPureToDefault() -> 13, 23
// testPureToView() -> 13, 23
