contract C {
    fallback() external {}

    fallback() external {}
}
// ----
// DeclarationError 7301: (96-118): Only one fallback fn is allowed.
