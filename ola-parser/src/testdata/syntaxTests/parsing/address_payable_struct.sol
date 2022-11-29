contract C {
    struct S {
        address payable a;
        address payable[] b;
        mapping(u256 => address payable) c;
        mapping(u256 => address payable[]) d;
    }
}
// ----
