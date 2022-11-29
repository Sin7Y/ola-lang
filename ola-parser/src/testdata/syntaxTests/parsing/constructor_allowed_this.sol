contract A {
    fn a() public pure {
    }
}
contract B {
    constructor(C) {
    }
    fn b(C) public returns (A) {
        return new A();
    }
}
contract C {
    B m_b;
    C m_c;
    constructor(C other_c) {
        m_c = other_c;
        m_b = new B(this);
        m_b.b(this).a();
        g(this).f();
        other_c.f();
        m_c.f();
    }
    fn f() public pure {
    }
    fn g(C) public view returns (C) {
        return m_c;
    }
}
// ----
