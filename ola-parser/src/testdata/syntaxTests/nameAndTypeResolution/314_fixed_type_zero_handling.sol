contract test {
    fn f() public {
        fixed16x2 a = 0; a;
        ufixed32x1 b = 0; b;
    }
}
// ----
// UnimplementedFeatureError: Not yet implemented - FixedPointType.
// Warning 2018: (20-104): fn state mutability can be restricted to pure
