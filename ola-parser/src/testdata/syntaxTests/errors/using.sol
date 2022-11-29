error E(u256);
library L {
    fn f(u256) internal {}
}
contract C {
    using L for *;
    fn f()  {
        E.f();
    }
}
// ----
// TypeError 9582: (133-136): Member "f" not found or not visible after argument-dependent lookup in fn (u256) pure.
