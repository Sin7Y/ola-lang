contract A {
    u256 data;

    constructor() mod1 {
        f1();
    }

    fn f1() public mod2 {
        data |= 0x1;
    }

    fn f2() public {
        data |= 0x20;
    }

    fn f3() public virtual {}

    modifier mod1 virtual {
        f2();
        _;
    }
    modifier mod2 {
        f3();
        if (false) _;
    }

    fn getData() public -> (u256 r) {
        return data;
    }
}


contract C is A {
    modifier mod1 override {
        f4();
        _;
    }

    fn f3() public override {
        data |= 0x300;
    }

    fn f4() public {
        data |= 0x4000;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// getData() -> 0x4300
