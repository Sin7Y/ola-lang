contract A {
    event X(u256);
}

contract B is A {
    event X(u256);
}
// ----
// DeclarationError 5883: (56-70): Event with same name and parameter types defined twice.
