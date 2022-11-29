contract B {
    fn ext() external {}
    fn pub() public {}
}

contract C is B {
    fn test() public pure {
        B.ext.selector;
        B.pub.selector;
        this.ext.selector;
        pub.selector;
    }
}

contract D {
    fn test() public pure {
        B.ext.selector;
        B.pub.selector;
    }
}
// ----
// Warning 6133: (136-150): Statement has no effect.
// Warning 6133: (160-174): Statement has no effect.
// Warning 6133: (184-201): Statement has no effect.
// Warning 6133: (289-303): Statement has no effect.
// Warning 6133: (313-327): Statement has no effect.
