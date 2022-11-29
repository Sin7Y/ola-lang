contract C1 {
    C1  bla;

    constructor(C1 x) {
        bla = x;
    }
}


contract C {
    fn test()  -> (C1 x, C1 y) {
        C1 c = new C1(C1(address(9)));
        x = c.bla();
        y = this.t1(C1(address(7)));
    }

    fn t1(C1 a)  -> (C1) {
        return a;
    }

    fn t2()  -> (C1) {
        return C1(address(9));
    }
}

// ====
// compileViaYul: also
// ----
// test() -> 9, 7
// gas legacy: 129760
// t2() -> 9
