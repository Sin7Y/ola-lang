contract test {
    fn f()  {
        int x;
        u256 y = u256(-x);
        -y;
    }
}
// ----
// TypeError 4907: (97-99): Unary operator - cannot be applied to type u256. Unary negation is only allowed for signed integers.
