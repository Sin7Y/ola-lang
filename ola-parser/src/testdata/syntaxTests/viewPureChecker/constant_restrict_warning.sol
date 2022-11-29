contract C {
    u256 constant x = 2;
    fn f() view  -> (u256) {
        return x;
    }
    fn g()  -> (u256) {
        return x;
    }
}
// ----
// Warning 2018: (42-107): fn state mutability can be restricted to pure
// Warning 2018: (112-172): fn state mutability can be restricted to pure
