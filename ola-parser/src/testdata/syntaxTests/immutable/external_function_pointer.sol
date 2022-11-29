contract C {
    fn() external immutable f;
}
// ----
// TypeError 3366: (17-48): Immutable variables of external fn type are not yet supported.
