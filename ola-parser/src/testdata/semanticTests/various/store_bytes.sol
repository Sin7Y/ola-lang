// this test just checks that the copy loop does not mess up the stack
contract C {
    fn save()  -> (u256 r) {
        r = 23;
        savedData = msg.data;
        r = 24;
    }

    bytes savedData;
}
// ====
// compileViaYul: also
// ----
// save() -> 24 # empty copy loop #
// save(): "abcdefg" -> 24
