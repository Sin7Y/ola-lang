contract c {
    u256 constant a1 = 0;
    u256 constant a2 = 1;
    u256 constant b1 = 7 / a1;
    u256 constant b2 = 7 / (a2 - 1);
}
// ----
// TypeError 1211: (88-94): Division by zero.
// TypeError 1211: (119-131): Division by zero.
