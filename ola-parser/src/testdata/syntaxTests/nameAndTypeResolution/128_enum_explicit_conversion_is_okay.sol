contract test {
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        Sit
    }

    constructor() {
        a = u256(ActionChoices.GoStraight);
        b = uint64(ActionChoices.Sit);
    }

    u256 a;
    uint64 b;
}
// ----
