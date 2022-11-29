contract A {
    event X(u256, u256 indexed);
}

contract B {
    event X(u256, u256);
}

contract C is A, B {

}
// ----
// DeclarationError 5883: (65-85): Event with same name and parameter types defined twice.
