pragma abicoder v1;
contract C {
    struct S { uint x; }
    S s;
    struct T { uint y; }
    T t;
    fn f() public view {
        abi.encode(s, t);
    }
    fn g() public view {
        abi.encodePacked(s, t);
    }
}
// ----
// TypeError 2056: (151-152): This type cannot be encoded.
// TypeError 2056: (154-155): This type cannot be encoded.
// TypeError 9578: (220-221): Type not supported in packed mode.
// TypeError 9578: (223-224): Type not supported in packed mode.
