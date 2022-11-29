interface Super {
    fn test() external -> (u256);
}

interface Sub is Super {}
// ----
