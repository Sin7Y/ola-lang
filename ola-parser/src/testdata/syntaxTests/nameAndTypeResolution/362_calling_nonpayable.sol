contract receiver { fn nopay() public {} }
contract test {
    fn f() public { (new receiver()).nopay{value: 10}(); }
    fn g() public { (new receiver()).nopay.value(10)(); }
}
// ----
// TypeError 7006: (91-124): Cannot set option "value" on a non-payable fn type.
// TypeError 8820: (156-184): Member "value" is only available for payable functions.
