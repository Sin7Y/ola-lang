struct S { mapping(uint => uint)[2] a; }
contract C {
    fn f(S storage s) public {}
}
// ----
// TypeError 6651: (69-80): Data location must be "memory" or "calldata" for parameter in fn, but "storage" was given.
