contract A {
    constructor() {
        address(this).call("123");
    }
}


contract B {
    u256 public test = 1;

    fn testIt() public {
        A a = new A();
        ++test;
    }
}

// ====
// compileViaYul: also
// ----
// testIt() ->
// test() -> 2
