contract test {
    enum ActionChoices {GoLeft, GoRight, GoStraight}

    constructor() {}

    fn getChoiceExp(u256 x)  -> (u256 d) {
        choice = ActionChoices(x);
        d = u256(choice);
    }

    fn getChoiceFromSigned(int256 x)  -> (u256 d) {
        choice = ActionChoices(x);
        d = u256(choice);
    }

    fn getChoiceFromMax()  -> (u256 d) {
        choice = ActionChoices(type(u256).max);
        d = u256(choice);
    }

    ActionChoices choice;
}

// ====
// EVMVersion: <byzantium
// compileViaYul: also
// ----
// getChoiceExp(u256): 3 -> FAILURE # These should throw #
// getChoiceFromSigned(int256): -1 -> FAILURE
// getChoiceFromMax() -> FAILURE
// getChoiceExp(u256): 2 -> 2 # These should work #
// getChoiceExp(u256): 0 -> 0
