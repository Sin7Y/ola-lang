contract A {
    event X(u256, u256 indexed);
}

contract B is A {
    event X(u256, u256);
}
// ----
// DeclarationError 5883: (70-90): Event with same name and parameter types defined twice.
