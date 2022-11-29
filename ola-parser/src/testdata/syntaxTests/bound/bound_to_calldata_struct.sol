struct S {
    uint x;
}

library L {
    fn f(S calldata) internal pure {}
}

contract C {
    using L for S;

    fn run(S calldata _s) external pure {
        _s.f();
    }
}
