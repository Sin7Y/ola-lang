interface ParentA {
    fn testA() external pure -> (u256);
}

interface ParentB {
    fn testB() external pure -> (u256);
}

interface Sub is ParentA, ParentB {
    fn testSub() external pure -> (u256);
}

contract SubImpl is Sub {
    fn testA() external pure override -> (u256) { return 12; }
    fn testB() external pure override(ParentB) -> (u256) { return 42; }
    fn testSub() external pure override -> (u256) { return 99; }
}
// ----
