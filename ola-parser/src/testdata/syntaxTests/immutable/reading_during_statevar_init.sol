contract C {
    u256 immutable x = 0;
    u256 y = x;
}
// ----
// TypeError 7733: (52-53): Immutable variables cannot be read before they are initialized.
