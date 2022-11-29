contract C {
    u256 immutable x;
}
// ----
// TypeError 2658: (0-36): Construction control flow ends without initializing all immutable state variables.
