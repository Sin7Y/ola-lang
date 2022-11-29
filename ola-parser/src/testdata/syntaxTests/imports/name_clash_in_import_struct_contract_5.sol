==== Source: a ====
struct A { u256 a; }
==== Source: b ====
import {A} from "a";
contract B {}
// ----
