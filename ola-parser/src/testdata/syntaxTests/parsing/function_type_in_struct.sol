contract test {
    struct S {
        fn (uint x, uint y) internal returns (uint) f;
        fn (uint, uint) external returns (uint) g;
        uint d;
    }
}
// ----
// Warning 6162: (49-55): Naming fn type parameters is deprecated.
// Warning 6162: (57-63): Naming fn type parameters is deprecated.
