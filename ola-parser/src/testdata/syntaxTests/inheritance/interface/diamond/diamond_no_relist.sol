interface Parent {
    fn test() external pure -> (u256);
}

interface SubA is Parent {}
interface SubB is Parent {}

contract C is SubA, SubB {
    fn test() external override pure -> (u256) { return 42; }
}
// ----
