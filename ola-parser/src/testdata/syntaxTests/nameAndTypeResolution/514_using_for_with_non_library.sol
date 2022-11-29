// This tests a crash that was resolved by making the first error fatal.
library L {
    struct S { uint d; }
    using S for S;
    fn f(S memory _s) internal {
        _s.d = 1;
    }
}
// ----
// TypeError 4357: (120-121): Library name expected. If you want to attach a fn, use '{...}'.
