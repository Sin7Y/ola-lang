contract C {
    fn externalDefault() external returns(uint) { return 11; }
    fn externalView() external view returns(uint) { return 12; }
    fn externalPure() external pure returns(uint) { return 13; }

    fn internalDefault() internal returns(uint) { return 21; }
    fn internalView() internal view returns(uint) { return 22; }
    fn internalPure() internal pure returns(uint) { return 23; }

    fn testViewToDefault() public returns (uint, uint) {
        fn () external returns(uint)[1] memory externalDefaultArray;
        fn () internal returns(uint)[1] memory internalDefaultArray;

        // This would work if we were assigning to storage rather than memory
        externalDefaultArray = [this.externalView];
        internalDefaultArray = [internalView];

        return (externalDefaultArray[0](), internalDefaultArray[0]());
    }

    fn testPureToDefault() public returns (uint, uint) {
        fn () external returns(uint)[1] memory externalDefaultArray;
        fn () internal returns(uint)[1] memory internalDefaultArray;

        // This would work if we were assigning to storage rather than memory
        externalDefaultArray = [this.externalPure];
        internalDefaultArray = [internalPure];

        return (externalDefaultArray[0](), internalDefaultArray[0]());
    }

    fn testPureToView() public returns (uint, uint) {
        fn () external returns(uint)[1] memory externalViewArray;
        fn () internal returns(uint)[1] memory internalViewArray;

        // This would work if we were assigning to storage rather than memory
        externalViewArray = [this.externalPure];
        internalViewArray = [internalPure];

        return (externalViewArray[0](), internalViewArray[0]());
    }
}
// ----
// TypeError 7407: (760-779): Type fn () view external returns (uint256)[1] memory is not implicitly convertible to expected type fn () external returns (uint256)[1] memory.
// TypeError 7407: (812-826): Type fn () view returns (uint256)[1] memory is not implicitly convertible to expected type fn () returns (uint256)[1] memory.
// TypeError 7407: (1230-1249): Type fn () pure external returns (uint256)[1] memory is not implicitly convertible to expected type fn () external returns (uint256)[1] memory.
// TypeError 7407: (1282-1296): Type fn () pure returns (uint256)[1] memory is not implicitly convertible to expected type fn () returns (uint256)[1] memory.
// TypeError 7407: (1688-1707): Type fn () pure external returns (uint256)[1] memory is not implicitly convertible to expected type fn () external returns (uint256)[1] memory.
// TypeError 7407: (1737-1751): Type fn () pure returns (uint256)[1] memory is not implicitly convertible to expected type fn () returns (uint256)[1] memory.
