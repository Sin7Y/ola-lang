contract C {
    fn a(u256 x) public -> (u256) {
        return x + 1;
    }

    fn b(u256 x) public -> (u256) {
        return x + 2;
    }

    fn c(u256 x) public -> (u256) {
        return x + 3;
    }

    fn d(u256 x) public -> (u256) {
        return x + 5;
    }

    fn e(u256 x) public -> (u256) {
        return x + 8;
    }

    fn test(u256 x, u256 i) public -> (u256) {
        fn(uint) internal -> (uint)[] memory arr =
            new fn(uint) internal -> (uint)[](10);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        return arr[i](x);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test(u256,u256): 10, 0 -> 11
// test(u256,u256): 10, 1 -> 12
// test(u256,u256): 10, 2 -> 13
// test(u256,u256): 10, 3 -> 15
// test(u256,u256): 10, 4 -> 18
// test(u256,u256): 10, 5 -> FAILURE, hex"4e487b71", 0x51
