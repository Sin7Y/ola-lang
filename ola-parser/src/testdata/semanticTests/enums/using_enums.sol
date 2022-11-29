contract test {
    enum ActionChoices {GoLeft, GoRight, GoStraight, Sit}

    constructor() {
        choices = ActionChoices.GoStraight;
    }

    fn getChoice()  -> (u256 d) {
        d = u256(choices);
    }

    ActionChoices choices;
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getChoice() -> 2
