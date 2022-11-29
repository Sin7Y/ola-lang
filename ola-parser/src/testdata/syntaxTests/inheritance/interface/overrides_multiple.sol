interface SuperA {
    fn test1() external -> (u256);
    fn test2() external -> (u256);
    fn test3() external -> (u256);
    fn test4() external -> (u256);
    fn test5() external -> (u256);
}

interface SuperB {
    fn test1() external -> (u256);
    fn test2() external -> (u256);
    fn test3() external -> (u256);
    fn test4() external -> (u256);
    fn test5() external -> (u256);
}

interface Sub is SuperA, SuperB {
    fn test1() external -> (u256);
    fn test2() external override -> (u256);
    fn test3() external override(SuperA) -> (u256);
    fn test4() external override(SuperB) -> (u256);
    fn test5() external override(SuperA, SuperB) -> (u256);
}

// ----
// TypeError 4327: (572-616): fn needs to specify overridden contracts "SuperA" and "SuperB".
// TypeError 4327: (647-655): fn needs to specify overridden contracts "SuperA" and "SuperB".
// TypeError 4327: (705-721): fn needs to specify overridden contract "SuperB".
// TypeError 4327: (771-787): fn needs to specify overridden contract "SuperA".
