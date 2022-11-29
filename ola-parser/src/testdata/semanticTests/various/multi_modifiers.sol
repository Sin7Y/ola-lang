// This triggered a bug in some version because the variable in the modifier was not
// unregistered correctly.
contract C {
    u256  x;
    modifier m1 {
        address a1 = msg.sender;
        x++;
        _;
    }

    fn f1()  m1() {
        x += 7;
    }

    fn f2()  m1() {
        x += 3;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f1() ->
// x() -> 0x08
// f2() ->
// x() -> 0x0c
