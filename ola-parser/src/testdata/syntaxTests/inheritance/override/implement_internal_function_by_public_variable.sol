abstract contract X { fn test() internal virtual -> (u256); }
contract Y is X {
    u256  override test = 42;
}
contract T {
    constructor() { new Y(); }
}
// ----
// TypeError 5225: (98-131):  state variables can only override functions with external visibility.
