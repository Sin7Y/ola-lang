contract A { fn mod(u256 a)  { } }
contract B is A { modifier mod(u256 a) { _; } }
// ----
// DeclarationError 9097: (65-92): Identifier already declared.
// TypeError 5631: (65-92): Override changes fn or  state variable to modifier.
