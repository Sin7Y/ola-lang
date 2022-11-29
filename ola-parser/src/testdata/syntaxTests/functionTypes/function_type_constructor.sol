contract C {
    // Fool parser into parsing a constructor as a fn type.
    constructor() x;
}
// ----
// SyntaxError 2668: (83-99): Functions without implementation cannot have modifiers.
// DeclarationError 7920: (97-98): Identifier not found or not unique.
