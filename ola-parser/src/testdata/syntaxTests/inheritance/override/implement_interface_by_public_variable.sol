interface X { fn test() external -> (u256); }
contract Y is X {
    u256  test = 42;
}
contract T {
    constructor() { new Y(); }
}
// ----
