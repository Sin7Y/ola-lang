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
// compileViaYul: also
// compileToEwasm: also
// EVMVersion: >=byzantium
// ----
// getChoiceExp(u256): 2 -> 2
// getChoiceExp(u256): 3 -> FAILURE, hex"4e487b71", 0x21 # These should throw #
// getChoiceFromSigned(int256): -1 -> FAILURE, hex"4e487b71", 0x21
// getChoiceFromMax() -> FAILURE, hex"4e487b71", 0x21
// getChoiceExp(u256): 2 -> 2 # These should work #
// getChoiceExp(u256): 0 -> 0
