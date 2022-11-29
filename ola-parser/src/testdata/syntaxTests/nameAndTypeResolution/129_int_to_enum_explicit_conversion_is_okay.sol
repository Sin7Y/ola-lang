contract test {
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        Sit
    }

    constructor() {
        a = 2;
        b = ActionChoices(a);
    }

    u256 a;
    ActionChoices b;
}
// ----
