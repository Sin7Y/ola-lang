library L {
    fn f() internal pure virtual -> (u256) { return 0; }
}
// ----
// TypeError 7801: (16-79): Library functions cannot be "virtual".
