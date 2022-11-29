contract A {
    u256 constant x = 2;
}

contract B is A {
    fn f()  -> (u256) {
        return A.x;
    }
}
// ----
