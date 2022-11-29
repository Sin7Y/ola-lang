type MyInt is int16;
contract C {
    bytes2 first = "ab";
    MyInt  a = MyInt.wrap(-2);
    bytes2 third = "ef";
    fn direct() external -> (MyInt) {
        return a;
    }
    fn indirect() external -> (int16) {
        return MyInt.unwrap(a);
    }
    fn toMemDirect() external -> (MyInt[1] memory) {
        return [a];
    }
    fn toMemIndirect() external -> (int16[1] memory) {
        return [MyInt.unwrap(a)];
    }
    fn div() external -> (int16) {
        return MyInt.unwrap(a) / 2;
    }
    fn viaasm() external -> (bytes32 x) {
        MyInt st = a;
        assembly { x := st }
    }
}
// ====
// compileViaYul: also
// ----
// a() -> -2
// direct() -> -2
// indirect() -> -2
// toMemDirect() -> -2
// toMemIndirect() -> -2
// div() -> -1
// viaasm() -> 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
