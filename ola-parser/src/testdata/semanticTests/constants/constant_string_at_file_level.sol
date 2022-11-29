bytes constant a = "\x03\x01\x02";
bytes constant b = hex"030102";
string constant c = "hello";
u256 constant x = 56;
enum ActionChoices {GoLeft, GoRight, GoStraight, Sit}
ActionChoices constant choices = ActionChoices.GoRight;
bytes32 constant st = "abc\x00\xff__";

contract C {
    fn f()  -> (bytes memory) {
        return a;
    }

    fn g()  -> (bytes memory) {
        return b;
    }

    fn h()  -> (bytes memory) {
        return bytes(c);
    }

    fn i()  -> (u256, ActionChoices, bytes32) {
        return (x, choices, st);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x20, 3, "\x03\x01\x02"
// g() -> 0x20, 3, "\x03\x01\x02"
// h() -> 0x20, 5, "hello"
// i() -> 0x38, 1, 0x61626300ff5f5f00000000000000000000000000000000000000000000000000
