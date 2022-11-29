library test {
    modifier m virtual;
    fn f() m  {
    }
}
// ----
// TypeError 3275: (19-38): Modifiers in a library cannot be virtual.
