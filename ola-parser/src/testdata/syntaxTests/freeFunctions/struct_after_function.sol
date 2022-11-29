fn f(S storage g) view -> (u256) { S storage t = g; return t.x; }
struct S { u256 x; }
// ----
