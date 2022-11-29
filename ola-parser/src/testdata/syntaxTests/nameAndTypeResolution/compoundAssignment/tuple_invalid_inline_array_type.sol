contract C {
    fn f() pure public {
        uint x;
        (x, ) = ([100e100]);
    }
}
// ----
// TypeError 9563: (78-85): Invalid mobile type.
