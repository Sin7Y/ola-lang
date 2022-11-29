contract C {
    u256 constant x = a;
    u256 constant a = b * c;
    u256 constant b = c;
    u256 constant c = b;
}
// ----
// TypeError 6161: (17-36): The value of the constant x has a cyclic dependency via a.
// TypeError 6161: (42-65): The value of the constant a has a cyclic dependency via b.
// TypeError 6161: (71-90): The value of the constant b has a cyclic dependency via c.
// TypeError 6161: (96-115): The value of the constant c has a cyclic dependency via b.
