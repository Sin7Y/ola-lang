contract C {
    fn f() public -> (uint) {
        return 0;
    }
    fn f(uint a) public -> (uint) {
        return a;
    }
    fn f(uint a, uint b) public -> (uint) {
        return a+b;
    }
    fn f(uint a, uint b, uint c) public -> (uint) {
        return a+b+c;
    }
    fn call(uint num) public -> (u256) {
        if (num == 0)
            return f();
        if (num == 1)
            return f({a: 1});
        if (num == 2)
            return f({b: 1, a: 2});
        if (num == 3)
            return f({c: 1, a: 2, b: 3});
        if (num == 4)
            return f({b: 5, c: 1, a: 2});

        return 500;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// call(u256): 0 -> 0
// call(u256): 1 -> 1
// call(u256): 2 -> 3
// call(u256): 3 -> 6
// call(u256): 4 -> 8
// call(u256): 5 -> 500
