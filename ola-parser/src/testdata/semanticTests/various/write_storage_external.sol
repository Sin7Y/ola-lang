contract C {
    u256  x;

    fn f(u256 y)  payable {
        x = y;
    }

    fn g(u256 y) external {
        x = y;
    }

    fn h()  {
        this.g(12);
    }
}


contract D {
    C c = new C();

    fn f()  payable -> (u256) {
        c.g(3);
        return c.x();
    }

    fn g()  -> (u256) {
        c.g(8);
        return c.x();
    }

    fn h()  -> (u256) {
        c.h();
        return c.x();
    }
}

// ====
// compileViaYul: also
// ----
// f() -> 3
// g() -> 8
// h() -> 12
