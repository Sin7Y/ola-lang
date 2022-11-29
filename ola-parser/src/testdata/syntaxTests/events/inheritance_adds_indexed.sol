contract A {
    event X(u256);
}

contract B is A {
    event X(u256 indexed);
}
// ----
// DeclarationError 5883: (56-78): Event with same name and parameter types defined twice.
