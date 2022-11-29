library L { fn l() public {} }
contract test {
    fn f() public {
        L.l{value: 1}();
    }
}
// ----
// TypeError 2193: (87-100): fn call options can only be set on external fn calls or contract creations.
