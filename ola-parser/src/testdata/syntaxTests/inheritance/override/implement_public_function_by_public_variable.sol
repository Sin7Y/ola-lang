abstract contract X { fn test() external virtual -> (u256); }
contract Y is X {
    u256  override test = 42;
}
contract T {
    constructor() { new Y(); }
}
// ----
