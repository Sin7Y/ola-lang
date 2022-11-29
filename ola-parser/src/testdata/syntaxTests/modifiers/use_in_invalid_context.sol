contract test {
    modifier mod() { _; }

    fn f()  {
        mod  ;
    }
}
// ----
// TypeError 3112: (77-80): Modifier can only be referenced in fn headers.
