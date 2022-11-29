==== Source: a ====
import "b";
u256 constant c = 7;
==== Source: b ====
import "a";
u256 constant c = 7;
// ----
// DeclarationError 2333: (b:12-31): Identifier already declared.
