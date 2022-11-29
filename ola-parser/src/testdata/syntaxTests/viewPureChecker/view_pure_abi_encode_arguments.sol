contract C {
    u256 x;
    fn gView()  -> (u256) { return x; }
    fn gNonPayable()  -> (u256) { x = 4; return 0; }

    fn f1() view  -> (bytes memory) {
        return abi.encode(gView());
    }
    fn f2() view  -> (bytes memory) {
        return abi.encodePacked(gView());
    }
    fn f3() view  -> (bytes memory) {
        return abi.encodeWithSelector(0x12345678, gView());
    }
    fn f4() view  -> (bytes memory) {
        return abi.encodeWithSignature("f(u256)", gView());
    }
    fn g1()  -> (bytes memory) {
        return abi.encode(gNonPayable());
    }
    fn g2()  -> (bytes memory) {
        return abi.encodePacked(gNonPayable());
    }
    fn g3()  -> (bytes memory) {
        return abi.encodeWithSelector(0x12345678, gNonPayable());
    }
    fn g4()  -> (bytes memory) {
        return abi.encodeWithSignature("f(u256)", gNonPayable());
    }
    // This will generate the only warning.
    fn check()  -> (bytes memory) {
        return abi.encode(2);
    }
}
// ----
// Warning 2018: (1100-1184): fn state mutability can be restricted to pure
