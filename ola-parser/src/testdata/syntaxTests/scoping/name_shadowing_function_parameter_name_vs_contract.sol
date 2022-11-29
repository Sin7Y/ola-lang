interface I {
    fn f(uint I) external;         // OK
}

library L {
    fn f(uint L) public pure {}    // warning
}

abstract contract A {
    fn f(uint A) public pure {}    // warning
    fn g(uint A) public virtual;   // OK
}

contract C {
    fn f(uint C) public pure {}    // warning
}
// ----
// Warning 2519: (91-97): This declaration shadows an existing declaration.
// Warning 2519: (168-174): This declaration shadows an existing declaration.
// Warning 2519: (283-289): This declaration shadows an existing declaration.
