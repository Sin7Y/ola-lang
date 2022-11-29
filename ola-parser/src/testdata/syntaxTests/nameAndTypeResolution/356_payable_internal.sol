contract test {
    fn f() payable internal {}
}
// ----
// TypeError 5587: (20-52): "internal" and "private" functions cannot be payable.
