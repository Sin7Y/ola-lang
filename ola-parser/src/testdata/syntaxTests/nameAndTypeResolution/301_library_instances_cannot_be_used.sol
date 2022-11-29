library L { fn l() public {} }
contract test {
    fn f() public {
        L x;
        x.l();
    }
}
// ----
// TypeError 1130: (87-88): Invalid use of a library name.
