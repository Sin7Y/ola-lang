type MyInt is int16;
type MyBytes is bytes2;
contract C {
    MyInt immutable a = MyInt.wrap(-2);
    MyBytes immutable b = MyBytes.wrap("ab");
    fn() internal -> (u256) immutable f = g;
    fn direct() view external -> (MyInt, MyBytes) {
        return (a, b);
    }
    fn viaasm() view external -> (bytes32 x, bytes32 y) {
        MyInt _a = a;
        MyBytes _b = b;
        assembly { x := _a y := _b }
    }
    fn g() internal pure -> (u256) { return 2; }
}
// ====
// compileViaYul: also
// ----
// direct() -> -2, 0x6162000000000000000000000000000000000000000000000000000000000000
// viaasm() -> 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe, 0x6162000000000000000000000000000000000000000000000000000000000000
