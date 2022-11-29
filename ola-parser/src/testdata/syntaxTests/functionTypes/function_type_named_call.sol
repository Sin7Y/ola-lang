contract C {
    fn f() pure public {
        fn(uint a) returns (uint) x;
        x({a:2});
    }
}
// ----
// Warning 6162: (61-67): Naming fn type parameters is deprecated.
// TypeError 4974: (95-103): Named argument "a" does not match fn declaration.
