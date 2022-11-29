abstract contract X { fn test() private virtual -> (u256); }
contract Y is X {
    u256  override test = 42;
}
contract T {
    constructor() { new Y(); }
}
// ----
// TypeError 5225: (97-130):  state variables can only override functions with external visibility.
// TypeError 3942: (22-72): "virtual" and "private" cannot be used together.
