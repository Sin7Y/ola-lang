interface SuperA {
    fn test() external -> (u256);
    fn testA() external -> (int128);
}

interface SuperB {
    fn test() external -> (u256);
    fn testB() external -> (int256);
}

interface Sub is SuperA, SuperB {
}

// ----
// TypeError 6480: (236-271): Derived contract must override fn "test". Two or more base classes define fn with same name and parameter types.
