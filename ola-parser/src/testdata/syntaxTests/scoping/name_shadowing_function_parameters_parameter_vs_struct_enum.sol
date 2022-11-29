library C {
    enum EnumType {A, B, C}

    struct StructType {
        uint x;
    }

    fn f1(fn (StructType memory StructType) external f) external {}
    fn f2(fn (EnumType EnumType) external f) external {}
    fn f3(fn (EnumType StructType, StructType memory EnumType) external f) external {}
}
// ----
// Warning 6162: (114-142): Naming fn type parameters is deprecated.
// Warning 6162: (194-211): Naming fn type parameters is deprecated.
// Warning 6162: (263-282): Naming fn type parameters is deprecated.
// Warning 6162: (284-310): Naming fn type parameters is deprecated.
// Warning 2519: (114-142): This declaration shadows an existing declaration.
// Warning 2519: (194-211): This declaration shadows an existing declaration.
// Warning 2519: (263-282): This declaration shadows an existing declaration.
// Warning 2519: (284-310): This declaration shadows an existing declaration.
