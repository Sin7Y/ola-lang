==== Source: a ====
contract A {}
==== Source: b ====
import {A} from "a";
struct B { u256 a; }
// ----
