library L { fn l() public {} }
contract test {
    fn f() public {
        L.l.value;
    }
}
// ----
// TypeError 8477: (87-96): Member "value" is not allowed in delegated calls due to "msg.value" persisting.
