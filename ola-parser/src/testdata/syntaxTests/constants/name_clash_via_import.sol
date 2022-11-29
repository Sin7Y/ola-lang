==== Source: a ====
u256 constant c = 7;
==== Source: b ====
import {c as d} from "a";
u256 constant d = 7;
// ----
// DeclarationError 2333: (b:26-45): Identifier already declared.
