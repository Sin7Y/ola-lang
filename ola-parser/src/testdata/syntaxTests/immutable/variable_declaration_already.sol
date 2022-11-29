contract C {
    u256 immutable z = 2;
    u256 immutable x = z = y = 3;
    u256 immutable y = 5;
}
// ----
// TypeError 1581: (66-67): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
// TypeError 1581: (62-63): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
