// Example from https://github.com/ethereum/solidity/issues/12558
pragma abicoder v2;
contract C {
    fn f(u256[] calldata a) external -> (u256[][] memory) {
        u256[][] memory m = new u256[][](2);
        m[0] = a;

        return m;
    }
}
contract Test {
    C immutable c = new C();

    fn test() external -> (bool) {
        u256[] memory arr = new u256[](4);

        arr[0] = 13;
        arr[1] = 14;
        arr[2] = 15;
        arr[3] = 16;

        u256[][] memory ret = c.f(arr);
        assert(ret.length == 2);
        assert(ret[0].length == 4);
        assert(ret[0][0] == 13);
        assert(ret[0][1] == 14);
        assert(ret[0][2] == 15);
        assert(ret[0][3] == 16);
        assert(ret[1].length == 0);

        return true;
    }
}
// ====
// EVMVersion: >homestead
// compileViaYul: also
// ----
// test() -> true
