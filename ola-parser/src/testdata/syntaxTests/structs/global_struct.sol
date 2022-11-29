struct S { uint a; }
contract C {
    fn f() public pure {
        S memory s = S(42);
        s;
    }
}
// ----
