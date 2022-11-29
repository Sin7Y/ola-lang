contract test {
    event A(u256 i);
    event A(u256 i);
}
// ----
// DeclarationError 5883: (20-36): Event with same name and parameter types defined twice.
