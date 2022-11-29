contract A { modifier mod(u256 a) { _; } }
contract B is A { fn mod(u256 a)  { } }
// ----
// DeclarationError 9097: (61-92): Identifier already declared.
// TypeError 1469: (61-92): Override changes modifier to fn.
