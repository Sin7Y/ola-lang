contract A {
    fixed40x40 storeMe;
    fn f(ufixed x, fixed32x32 y) public {
        ufixed8x8 a;
        fixed b;
    }
}
// ----
// UnimplementedFeatureError: Fixed point types not implemented.
// Warning 5667: (52-60): Unused fn parameter. Remove or comment out the variable name to silence this warning.
// Warning 5667: (62-74): Unused fn parameter. Remove or comment out the variable name to silence this warning.
// Warning 2072: (93-104): Unused local variable.
// Warning 2072: (114-121): Unused local variable.
// Warning 2018: (41-128): fn state mutability can be restricted to pure
