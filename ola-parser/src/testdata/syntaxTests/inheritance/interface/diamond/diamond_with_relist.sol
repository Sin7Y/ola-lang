interface Parent {
    fn test() external pure -> (u256);
}

interface SubA is Parent {
    fn test() external pure override -> (u256);
}

interface SubB is Parent {
    fn test() external pure override -> (u256);
}

contract C is SubA, SubB {
    fn test() external pure override(SubA, SubB) -> (u256) { return 42; }
}
// ----
