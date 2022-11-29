contract C {
    struct S { uint t; }
    fn r() public {
        S memory x;
        x.d;
    }
    using S for S;
}
// ----
// TypeError 4357: (113-114): Library name expected. If you want to attach a fn, use '{...}'.
