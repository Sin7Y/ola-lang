contract C {
    enum E {a, b, c}
    struct S {fn (E X) external f; uint E;}
    struct T {fn (E T) external f; uint E;}
    struct U {fn (E E) external f;}
}
// ----
// Warning 6162: (58-61): Naming fn type parameters is deprecated.
// Warning 6162: (108-111): Naming fn type parameters is deprecated.
// Warning 6162: (158-161): Naming fn type parameters is deprecated.
// Warning 2519: (108-111): This declaration shadows an existing declaration.
// Warning 2519: (158-161): This declaration shadows an existing declaration.
