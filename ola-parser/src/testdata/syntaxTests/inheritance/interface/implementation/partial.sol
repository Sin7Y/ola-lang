interface ParentA {
    fn testA() external -> (u256);
}

interface ParentB {
    fn testB() external -> (u256);
}

interface Sub is ParentA, ParentB {
    fn testSub() external -> (u256);
}

contract SubImpl is Sub {
    fn testA() external override -> (u256) { return 12; }
    fn testSub() external override -> (u256) { return 99; }
}

// ----
// TypeError 3656: (234-407): Contract "SubImpl" should be marked as abstract.
