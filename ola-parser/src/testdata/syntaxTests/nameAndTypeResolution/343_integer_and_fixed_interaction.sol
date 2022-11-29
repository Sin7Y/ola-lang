contract test {
    fn f() public {
        ufixed a = uint64(1) + ufixed(2);
    }
}
// ----
// UnimplementedFeatureError: Not yet implemented - FixedPointType.
// Warning 2072: (50-58): Unused local variable.
// Warning 2018: (20-89): fn state mutability can be restricted to pure
