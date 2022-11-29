contract D {}
contract C {
    fn foo(int a) pure internal {
        foo{gas: 5};
    }
}
// ----
// TypeError 2193: (75-86): fn call options can only be set on external fn calls or contract creations.
