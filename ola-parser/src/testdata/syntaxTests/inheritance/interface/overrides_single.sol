interface Super {
    fn test1() external -> (u256);
    fn test2() external -> (u256);
    fn test3() external -> (u256);
}

interface Sub is Super {
    fn test1() external -> (u256);
    fn test2() external override -> (u256);
    fn test3() external override(Super) -> (u256);
}

// ----
